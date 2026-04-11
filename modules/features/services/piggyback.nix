{ den, inputs, ... }:
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
                    lib,
                    pkgs,
                    system,
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
                            serviceConfig = {
                                Type = "oneshot";
                                ExecStart = lib.getExe inputs.piggyback.defaultPackage.${system};
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
