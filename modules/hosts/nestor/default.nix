{
    den,
    inputs,
    ...
}:
{
    flake-file.inputs.nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/nixos-unstable";

    den.aspects.nestor = {
        provides.to-users.includes = with den.aspects; [
            security._.sudo

            programs._.fish
            programs._.bottom
            programs._.nix
        ];

        nixos =
            {
                config,
                lib,
                pkgs,
                ...
            }:
            {
                imports = [
                    inputs.nixos-raspberrypi.nixosModules.raspberry-pi-02.base
                ];

                boot = {
                    # We need to force this so we can remove "console=serial0,115200"
                    # https://github.com/nvmd/nixos-raspberrypi/issues/97
                    kernelParams = lib.mkForce [
                        "console=tty1"
                        "root=fstab"
                        "loglevel=3"
                        "lsm=landlock,yama,bpf"
                    ];
                    kernelPackages = pkgs.linuxPackages_latest;
                    loader.raspberry-pi.bootloader = "kernel";
                };

                time.timeZone = "America/Los_Angeles";

                zramSwap.enable = true;
                i18n.defaultLocale = "en_US.UTF-8";
                users.mutableUsers = false;

                networking = {
                    useDHCP = true;
                    wireless = {
                        enable = true;
                        secretsFile = config.sops.templates.nestor-wireless-secrets.path;
                        networks.dirk_diggler.pskRaw = "ext:nestor_wifi_passphrase";
                    };
                };
                services.openssh.enable = true;

                # https://help.prusa3d.com/article/octoprint-configuration-and-install_2182#using-ssh
                hardware.raspberry-pi.config.all.dt-overlays.pi3-miniuart-bt.enable = true;

                system.nixos.tags = [
                    "raspberry-pi-${config.boot.loader.raspberry-pi.variant}"
                    config.boot.loader.raspberry-pi.bootloader
                    config.boot.kernelPackages.kernel.version
                ];

                sops = {
                    templates.nestor-wireless-secrets = {
                        content = ''
                            nestor_wifi_passphrase=${config.sops.placeholder."nestor/wifi/passphrase"}
                        '';
                        owner = "wpa_supplicant";
                    };
                    secrets."nestor/wifi/passphrase" = { };
                };

                system.stateVersion = "25.11";
            };

        provides.cassidy.homeManager =
            { ... }:
            {
                home.shellAliases = {
                    jrn = "sudo journalctl";
                    sys = "sudo systemctl";
                };

                programs.neovim = {
                    enable = true;
                    defaultEditor = true;
                    viAlias = true;
                    vimAlias = true;

                    withNodeJs = false;
                    withPython3 = false;
                    withRuby = false;
                };
            };
    };
}
