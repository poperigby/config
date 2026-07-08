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
            programs._.tealdeer
            programs._.television
            programs._.yazi
        ];

        nixos =
            {
                config,
                lib,
                ...
            }:
            {
                imports = [ inputs.nixos-raspberrypi.nixosModules.raspberry-pi-02.base ];

                boot = {
                    # We need to force this so we can remove "console=serial0,115200"
                    # https://github.com/nvmd/nixos-raspberrypi/issues/97
                    kernelParams = lib.mkForce [
                        "console=tty1"
                        "root=fstab"
                        "loglevel=3"
                        "lsm=landlock,yama,bpf"
                    ];
                    loader.raspberry-pi.bootloader = "kernel";
                    tmp.useTmpfs = true;
                };

                time.timeZone = "America/Los_Angeles";

                networking.networkmanager.enable = true;

                services = {
                    octoprint = {
                        enable = true;
                        openFirewall = true;
                        plugins =
                            plugins: with plugins; [
                                navbartemp
                                simpleemergencystop
                                themeify
                            ];
                    };
                    openssh.enable = true;
                };

                # https://help.prusa3d.com/article/octoprint-configuration-and-install_2182#using-ssh
                hardware.raspberry-pi.config.all.dt-overlays.pi3-miniuart-bt.enable = true;

                system.nixos.tags = [
                    "raspberry-pi-${config.boot.loader.raspberry-pi.variant}"
                    config.boot.loader.raspberry-pi.bootloader
                    config.boot.kernelPackages.kernel.version
                ];

                system.stateVersion = "25.11";
            };
    };
}
