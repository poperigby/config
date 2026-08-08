{ den, ... }:

{
    den.aspects.services.provides.backup.checks =
        { ... }:
        {
            nixos =
                {
                    config,
                    lib,
                    pkgs,
                    ...
                }:
                let
                    name = "borgbase";
                    restic = lib.getExe config.services.restic.backups.${name}.package;
                    backupEnv = config.systemd.services."restic-backups-${name}".environment;
                    environment = {
                        RESTIC_PASSWORD_FILE = backupEnv.RESTIC_PASSWORD_FILE;
                        RESTIC_REPOSITORY_FILE = backupEnv.RESTIC_REPOSITORY_FILE;
                    };
                in
                {
                    systemd.services = {
                        "restic-check-${name}" = {
                            description = "Structural integrity check for the ${name} Restic repository";
                            inherit environment;
                            unitConfig.OnFailure = "notify-backup-failure@%n.service";
                            serviceConfig = {
                                Type = "oneshot";
                                ExecStart = "${restic} check --retry-lock 1h";
                            };
                        };
                        "restic-check-data-${name}" = {
                            description = "Rotating data integrity check for the ${name} Restic repository";
                            inherit environment;
                            unitConfig.OnFailure = "notify-backup-failure@%n.service";
                            serviceConfig = {
                                Type = "oneshot";
                                ExecStart = lib.getExe (
                                    pkgs.writeShellScriptBin "restic-check-data-${name}" ''
                                        subset="$(${lib.getExe' pkgs.coreutils "date"} +%-m)/12"
                                        exec ${restic} check --retry-lock 1h --read-data-subset "$subset"
                                    ''
                                );
                            };
                        };
                        "restic-check-full-${name}" = {
                            description = "Full data integrity check for the ${name} Restic repository";
                            inherit environment;
                            unitConfig.OnFailure = "notify-backup-failure@%n.service";
                            serviceConfig = {
                                Type = "oneshot";
                                ExecStart = "${restic} check --retry-lock 1h --read-data";
                            };
                        };
                    };

                    systemd.timers = {
                        "restic-check-${name}" = {
                            wantedBy = [ "timers.target" ];
                            timerConfig = {
                                OnCalendar = "Sun *-*-* 04:00:00";
                                Persistent = true;
                            };
                        };
                        "restic-check-data-${name}" = {
                            wantedBy = [ "timers.target" ];
                            timerConfig = {
                                OnCalendar = "*-*-08 06:00:00";
                                Persistent = true;
                            };
                        };
                        "restic-check-full-${name}" = {
                            wantedBy = [ "timers.target" ];
                            timerConfig = {
                                OnCalendar = "*-01-22 06:00:00";
                                Persistent = true;
                            };
                        };
                    };
                };
        };
}
