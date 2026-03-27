{
    config,
    lib,
    pkgs,
    ...
}:

let
    inherit (lib)
        getExe
        getExe'
        mkEnableOption
        mkIf
        mkMerge
        mkOption
        optionalAttrs
        optionals
        ;

    inherit (lib.types)
        bool
        listOf
        str
        submodule
        ;

    cfg = config.custom.services.backups;
    hostName = config.networking.hostName;
    mail = config.custom.services.postfix.enable;
in
{
    options.custom.services.backups = {
        enable = mkEnableOption "Restic backups";
        repositories = mkOption {
            default = {
                borgbase = true;
            };
            type = submodule {
                options = {
                    borgbase = mkOption {
                        type = bool;
                        default = true;
                        description = "Enable BorgBase";
                    };
                    tintin = mkEnableOption "Tintin";
                };
            };
        };
        paths = mkOption {
            type = listOf str;
        };
        databases = mkOption {
            type = bool;
            default = config.services.postgresql.enable;
            description = "Enable backup of PostgreSQL databases";
        };
        exclude = mkOption {
            type = listOf str;
            default = [ ];
        };
        frequency = mkOption {
            type = str;
            default = "daily";
        };
    };

    config =
        let
            btrfs = getExe pkgs.btrfs-progs;
            grep = getExe pkgs.ripgrep;
            mount = getExe' pkgs.util-linux "mount";
            umount = getExe' pkgs.util-linux "umount";

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
                    ++ optionals cfg.databases [
                        # The database backup is stored as a separate snapshot that's tagged with "database"
                        # Pruning operates on groups, so it will separately prune "system" and "database" snapshots
                        "--group-by tags"
                    ];
                    extraBackupArgs = [ "--tag system" ];
                    backupPrepareCommand = # bash
                        ''
                            set -euo pipefail

                            # Clean up old snapshots if necessary
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

                            # Create snapshots and bind mount them to their correct locations under /, so everything will appear normal to Restic
                            # We're running in a private mount namespace, so remounting things is safe
                            ${btrfs} subvolume snapshot -r /home /.snapshots/@restic-home
                            ${umount} /home
                            ${mount} --bind /.snapshots/@restic-home /home

                            if ${btrfs} subvolume list / | ${grep} -q "@var_lib"; then
                                ${btrfs} subvolume snapshot -r /var/lib /.snapshots/@restic-var_lib
                                ${umount} /var/lib
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
                    paths = cfg.paths;
                    exclude = cfg.exclude;
                    timerConfig.OnCalendar = cfg.frequency;
                };

                systemd.services = {
                    "restic-backups-${name}" = {
                        unitConfig.OnFailure = mkIf mail "notify-failure-email@%i";

                        # Run backup in a separate mount namespace so we can mount
                        # a snapshot to the correct location
                        serviceConfig.PrivateMounts = true;

                    }
                    // optionalAttrs cfg.databases {
                        # Run our database dump first so pruning will apply to both snapshots
                        wants = [ "restic-backups-${name}-db.service" ];
                        after = [ "restic-backups-${name}-db.service" ];
                    };
                    "restic-backups-${name}-db" = mkIf cfg.databases {
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
                                    pg_dumpall = getExe' config.services.postgresql.package "pg_dumpall";
                                    restic = getExe config.services.restic.backups.${name}.package;
                                in
                                getExe (
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

                # The correct secrets will automatically be used based on the hostname
                sops.secrets = {
                    "${hostName}/restic/${name}/url" = { };
                    "${hostName}/restic/${name}/password" = { };
                };
            };
        in
        mkIf cfg.enable (mkMerge [
            (mkIf cfg.repositories.borgbase (mkRepoCfg "borgbase"))
            (mkIf cfg.repositories.tintin (mkRepoCfg "tintin"))
        ]);
}
