{ den, ... }:
{
    den.aspects.services.provides.backups =
        {
            paths,
            exclude ? [ ],
            repositories ? {
                borgbase = true;
                tintin = false;
            },
            databases ? null,
            frequency ? "daily",
        }:
        {
            nixos =
                {
                    config,
                    lib,
                    pkgs,
                    ...
                }:
                let
                    btrfs = lib.getExe pkgs.btrfs-progs;
                    grep = lib.getExe pkgs.ripgrep;
                    mount = lib.getExe' pkgs.util-linux "mount";
                    umount = lib.getExe' pkgs.util-linux "umount";

                    hostName = config.networking.hostName;
                    mail = config.services.postfix.enable;
                    databases' = if databases == null then config.services.postgresql.enable else databases;

                    mkRepoCfg = name: {
                        services.restic.backups.${name} = {
                            repositoryFile = config.sops.secrets."${hostName}/restic/${name}/url".path;
                            passwordFile = config.sops.secrets."${hostName}/restic/${name}/password".path;
                            initialize = true;
                            pruneOpts = [
                                "--keep-daily 7"
                                "--keep-weekly 4"
                                "--keep-monthly 3"
                                "--keep-yearly 1"
                            ]
                            ++ lib.optionals databases' [
                                "--group-by tags"
                            ];
                            extraBackupArgs = [ "--tag system" ];
                            backupPrepareCommand = ''
                                set -euo pipefail

                                deleted_any=false
                                for subvol in "@restic-home" "@restic-var_lib"; do
                                  if ${btrfs} subvolume list /.snapshots | ${grep} -q "$subvol"; then
                                    ${btrfs} subvolume delete /.snapshots/$subvol
                                    deleted_any=true
                                  fi
                                done
                                if $deleted_any; then
                                  echo "WARNING: Previous run did not cleanly finish, removing old snapshot(s)"
                                fi

                                ${btrfs} subvolume snapshot -r /home /.snapshots/@restic-home
                                ${umount} /home
                                ${mount} --bind /.snapshots/@restic-home /home

                                if ${btrfs} subvolume list / | ${grep} -q "@var_lib"; then
                                  ${btrfs} subvolume snapshot -r /var/lib /.snapshots/@restic-var_lib
                                  ${umount} /var/lib
                                  ${mount} --bind /.snapshots/@restic-var_lib /var/lib
                                fi
                            '';
                            backupCleanupCommand = ''
                                set -euo pipefail

                                for subvol in "@restic-home" "@restic-var_lib"; do
                                  if ${btrfs} subvolume list /.snapshots | ${grep} -q "$subvol"; then
                                    ${btrfs} subvolume delete /.snapshots/$subvol
                                  fi
                                done
                            '';
                            inherit paths exclude;
                            timerConfig.OnCalendar = frequency;
                        };

                        systemd.services = {
                            "restic-backups-${name}" = {
                                unitConfig.OnFailure = lib.mkIf mail "notify-failure-email@%i";
                                serviceConfig.PrivateMounts = true;
                            }
                            // lib.optionalAttrs databases' {
                                wants = [ "restic-backups-${name}-db.service" ];
                                after = [ "restic-backups-${name}-db.service" ];
                            };

                            "restic-backups-${name}-db" = lib.mkIf databases' {
                                description = "PostgreSQL Restic backup for ${name}";

                                environment =
                                    let
                                        backupEnv = config.systemd.services."restic-backups-${name}".environment;
                                    in
                                    {
                                        RESTIC_CACHE_DIR = backupEnv.RESTIC_CACHE_DIR;
                                        RESTIC_PASSWORD_FILE = backupEnv.RESTIC_PASSWORD_FILE;
                                        RESTIC_REPOSITORY_FILE = backupEnv.RESTIC_REPOSITORY_FILE;
                                    };

                                serviceConfig = {
                                    Type = "oneshot";
                                    ExecStart =
                                        let
                                            pg_dumpall = lib.getExe' config.services.postgresql.package "pg_dumpall";
                                            restic = lib.getExe config.services.restic.backups.${name}.package;
                                        in
                                        lib.getExe (
                                            pkgs.writeShellScriptBin "database-backup" ''
                                                set -euo pipefail

                                                ${restic} backup \
                                                  --tag database \
                                                  --stdin-filename all.sql \
                                                  --stdin-from-command -- \
                                                  ${pg_dumpall} --clean --if-exists
                                            ''
                                        );
                                };
                            };
                        };

                        sops.secrets = {
                            "${hostName}/restic/${name}/url" = { };
                            "${hostName}/restic/${name}/password" = { };
                        };
                    };
                in
                lib.mkMerge [
                    (lib.mkIf (repositories.borgbase or false) (mkRepoCfg "borgbase"))
                    (lib.mkIf (repositories.tintin or false) (mkRepoCfg "tintin"))
                ];
        };
}
