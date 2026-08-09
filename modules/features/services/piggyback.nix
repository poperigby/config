{ ... }:
{
    flake-file.inputs = {
        piggyback = {
            url = "git+https://codeberg.org/PopeRigby/piggyback.git";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    den.aspects.services.provides.piggyback =
        {
            environmentFile,
            user ? "piggyback",
            group ? "piggyback",
        }:
        {
            nixos =
                {
                    inputs',
                    lib,
                    ...
                }:
                {
                    users = {
                        users.${user} = {
                            isSystemUser = true;
                            group = group;
                        };
                        groups.${group} = { };
                    };

                    systemd = {
                        services.piggyback = {
                            description = "Piggyback DDNS updater";
                            wants = [ "network-online.target" ];
                            after = [ "network-online.target" ];
                            serviceConfig = {
                                Type = "oneshot";
                                ExecStart = lib.getExe inputs'.piggyback.defaultPackage;
                                EnvironmentFile = environmentFile;
                                User = user;
                                Group = group;
                            };
                        };
                        timers.piggyback = {
                            description = "Run Piggyback every 15 minutes";
                            wantedBy = [ "timers.target" ];
                            timerConfig = {
                                OnBootSec = "1min";
                                OnUnitActiveSec = "15min";
                                AccuracySec = "1min";
                            };
                        };
                    };
                };
        };
}
