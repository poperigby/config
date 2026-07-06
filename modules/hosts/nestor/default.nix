{
    den,
    inputs,
    ...
}:
{
    flake-file.inputs.nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/nixos-unstable";

    den.aspects.nestor = {
        provides.to-users.includes = with den.aspects; [
            common

            programs._.atuin
            programs._.bat
            programs._.bottom
            programs._.direnv
            programs._.fish
            programs._.git
            programs._.gpg
            programs._.jujutsu
            programs._.neovim
            programs._.starship
            programs._.tealdeer
            programs._.television
            programs._.yazi
        ];

        nixos =
            {
                config,
                ...
            }:
            {
                imports = [ inputs.nixos-raspberrypi.nixosModules.raspberry-pi-02.base ];

                boot = {
                    loader.raspberry-pi.bootloader = "kernel";
                    tmp.useTmpfs = true;
                    kernelParams = [ "loglevel=3" ];
                };

                time.timeZone = "America/Los_Angeles";

                networking.networkmanager.enable = true;

                services = {
                    octoprint = {
                        enable = true;
                        openFirewall = true;
                    };
                    openssh = {
                        enable = true;
                        settings = {
                            PermitRootLogin = "no";
                            MaxAuthTries = 3;
                            PasswordAuthentication = true;
                            PermitEmptyPasswords = false;
                            ChallengeResponseAuthentication = false;
                            PermitUserEnvironment = false;
                            AllowAgentForwarding = false;
                            PermitTunnel = false;
                        };
                    };

                };

                system.nixos.tags = [
                    "raspberry-pi-${config.boot.loader.raspberry-pi.variant}"
                    config.boot.loader.raspberry-pi.bootloader
                    config.boot.kernelPackages.kernel.version
                ];

                system.stateVersion = "25.11";
            };
    };
}
