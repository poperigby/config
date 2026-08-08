{ den, ... }:

{
    den.aspects.services.provides.backups =
        {
            paths,
            exclude ? [ ],
            databases ? null,
            frequency ? "daily",
        }@args:
        {
            includes = with den.aspects.services._; [
                postfix
                (backup.postgresql args)
                (backup.checks args)
            ];

            nixos =
                {
                    config,
                    lib,
                    pkgs,
                    ...
                }:
                let
                    name = "borgbase";
                    hostName = config.networking.hostName;
                    databases' = if databases == null then config.services.postgresql.enable else databases;
                    btrfs = lib.getExe pkgs.btrfs-progs;
                    grep = lib.getExe pkgs.ripgrep;
                    mount = lib.getExe' pkgs.util-linux "mount";
                    notifyFailure = pkgs.writeShellApplication {
                        name = "notify-backup-failure";
                        text = ''
                            unit="$1"

                            {
                              printf 'To: root\n'
                              printf 'From: Restic <haddock@mailbox.org>\n'
                              printf 'Subject: Restic job failed on %s: %s\n' ${lib.escapeShellArg hostName} "$unit"
                              printf 'Content-Type: text/plain; charset=UTF-8\n'
                              printf '\n'
                              ${lib.getExe' pkgs.systemd "journalctl"} --boot --unit "$unit" --lines 100 --no-pager
                            } | /run/wrappers/bin/sendmail -t
                        '';
                    };
                in
                {
                    services.restic.backups.${name} = {
                        repositoryFile = config.sops.secrets."${hostName}/restic/${name}/url".path;
                        passwordFile = config.sops.secrets."${hostName}/restic/${name}/password".path;
                        initialize = true;
                        pruneOpts = [
                            "--keep-daily 14"
                            "--keep-weekly 8"
                            "--keep-monthly 12"
                            "--keep-yearly 3"
                        ]
                        ++ lib.optionals databases' [ "--group-by tags" ];
                        extraBackupArgs = [ "--tag system" ];
                        backupPrepareCommand = # bash
                            ''
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
                                ${mount} --bind /.snapshots/@restic-home /home

                                # Some hosts do not place /var/lib in a dedicated Btrfs subvolume.
                                # TODO: FUCKING WHY?
                                if ${btrfs} subvolume list / | ${grep} -q "@var_lib"; then
                                  ${btrfs} subvolume snapshot -r /var/lib /.snapshots/@restic-var_lib
                                  ${mount} --bind /.snapshots/@restic-var_lib /var/lib
                                fi
                            '';
                        backupCleanupCommand = # bash
                            ''
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
                            unitConfig.OnFailure = "notify-backup-failure@%n.service";
                            serviceConfig.PrivateMounts = true;
                        }
                        // lib.optionalAttrs databases' {
                            wants = [ "restic-backups-${name}-db.service" ];
                            after = [ "restic-backups-${name}-db.service" ];
                        };

                        "notify-backup-failure@" = {
                            description = "Email notification for failed Restic unit %I";
                            serviceConfig = {
                                Type = "oneshot";
                                ExecStart = "${lib.getExe notifyFailure} %I";
                            };
                        };
                    };

                    sops.secrets = {
                        "${hostName}/restic/${name}/url" = { };
                        "${hostName}/restic/${name}/password" = { };
                    };
                };
        };
}
