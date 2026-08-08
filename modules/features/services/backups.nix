{ den, ... }:
{
    # Create one complete backup stack per enabled repository: a filesystem
    # backup, an optional PostgreSQL dump, retention, integrity checks, and
    # failure notification. Callers decide which irreplaceable paths belong in
    # the filesystem snapshot.
    den.aspects.services.provides.backups =
        {
            paths,
            exclude ? [ ],
            databases ? null,
            frequency ? "daily",
        }:
        {
            # Every generated failure unit sends mail through the local MTA.
            includes = [ den.aspects.services._.postfix ];

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

                    hostName = config.networking.hostName;
                    # Follow PostgreSQL automatically unless the caller makes an
                    # explicit choice. This keeps database state out of a
                    # crash-consistent filesystem copy.
                    databases' = if databases == null then config.services.postgresql.enable else databases;

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

                    mkRepoCfg =
                        name:
                        let
                            restic = lib.getExe config.services.restic.backups.${name}.package;
                            # Integrity checks need repository credentials, but
                            # intentionally omit RESTIC_CACHE_DIR. By default,
                            # `restic check` then builds a fresh temporary cache
                            # instead of trusting cached repository metadata.
                            checkEnvironment =
                                let
                                    backupEnv = config.systemd.services."restic-backups-${name}".environment;
                                in
                                {
                                    RESTIC_PASSWORD_FILE = backupEnv.RESTIC_PASSWORD_FILE;
                                    RESTIC_REPOSITORY_FILE = backupEnv.RESTIC_REPOSITORY_FILE;
                                };
                        in
                        {
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
                                    # System and database snapshots have
                                    # independent retention histories.
                                    "--group-by tags"
                                ];
                                extraBackupArgs = [ "--tag system" ];
                                # Restic reads bind-mounted, read-only Btrfs
                                # snapshots. PrivateMounts below confines these
                                # temporary mount replacements to this unit, so
                                # services continue using the live filesystems.
                                backupPrepareCommand = # bash
                                    ''
                                        set -euo pipefail

                                        deleted_any=false
                                        # A killed or crashed run may leave its
                                        # snapshot subvolumes behind.
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

                                        # Some hosts do not place /var/lib in a
                                        # dedicated Btrfs subvolume.
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
                                "notify-backup-failure@" = {
                                    description = "Email notification for failed Restic unit %I";
                                    serviceConfig = {
                                        Type = "oneshot";
                                        ExecStart = "${lib.getExe notifyFailure} %I";
                                    };
                                };

                                "restic-backups-${name}" = {
                                    unitConfig.OnFailure = "notify-backup-failure@%n.service";
                                    # Required for the snapshot bind mounts not
                                    # to replace /home and /var/lib system-wide.
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

                                                    # Keep logical database backups separate from filesystem snapshots.
                                                    ${restic} backup \
                                                      --tag database \
                                                      --stdin-filename all.sql \
                                                      --stdin-from-command -- \
                                                      ${pg_dumpall} --clean --if-exists
                                                ''
                                            );
                                    };
                                };

                                "restic-check-${name}" = {
                                    description = "Structural integrity check for the ${name} Restic repository";
                                    environment = checkEnvironment;
                                    unitConfig.OnFailure = "notify-backup-failure@%n.service";
                                    serviceConfig = {
                                        Type = "oneshot";
                                        # A backup or prune may legitimately
                                        # hold the repository lock. Wait rather
                                        # than raising a false alarm.
                                        ExecStart = "${restic} check --retry-lock 1h";
                                    };
                                };

                                "restic-check-data-${name}" = {
                                    description = "Rotating data integrity check for the ${name} Restic repository";
                                    environment = checkEnvironment;
                                    unitConfig.OnFailure = "notify-backup-failure@%n.service";
                                    serviceConfig = {
                                        Type = "oneshot";
                                        ExecStart = lib.getExe (
                                            pkgs.writeShellScriptBin "restic-check-data-${name}" ''
                                                set -euo pipefail

                                                # Restic partitions packs
                                                # deterministically. Selecting the
                                                # calendar month's partition checks
                                                # every stored pack once per year.
                                                subset="$(${lib.getExe' pkgs.coreutils "date"} +%-m)/12"
                                                    exec ${restic} check --retry-lock 1h --read-data-subset "$subset"
                                            ''
                                        );
                                    };
                                };
                            };

                            systemd.timers = {
                                # Checks are deliberately separate from the
                                # daily backup unit: an expensive or transiently
                                # failing verification cannot invalidate a
                                # successfully created snapshot.
                                "restic-check-${name}" = {
                                    description = "Weekly structural integrity check for the ${name} Restic repository";
                                    wantedBy = [ "timers.target" ];
                                    timerConfig = {
                                        # Runs after the midnight daily backup.
                                        OnCalendar = "Sun *-*-* 04:00:00";
                                        Persistent = true;
                                    };
                                };

                                "restic-check-data-${name}" = {
                                    description = "Monthly rotating data integrity check for the ${name} Restic repository";
                                    wantedBy = [ "timers.target" ];
                                    timerConfig = {
                                        # Avoid the Btrfs scrub dates (1 and 15).
                                        OnCalendar = "*-*-08 06:00:00";
                                        Persistent = true;
                                    };
                                };
                            };

                            sops.secrets = {
                                "${hostName}/restic/${name}/url" = { };
                                "${hostName}/restic/${name}/password" = { };
                            };
                        };
                in
                mkRepoCfg "borgbase";
        };
}
