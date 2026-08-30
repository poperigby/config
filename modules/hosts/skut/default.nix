{ ... }:
{
    den.aspects.skut.nixos =
        {
            lib,
            pkgs,
            modulesPath,
            ...
        }:
        let
            inherit (lib) mkForce;
        in
        {
            imports = [
                (modulesPath + "/profiles/minimal.nix")
                (modulesPath + "/profiles/installation-device.nix")
            ];

            image.modules.iso =
                { modulesPath, ... }:
                {
                    imports = [
                        (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
                    ];
                };

            fileSystems."/" = {
                device = "tmpfs";
                fsType = "tmpfs";
            };
            boot.loader.grub.devices = [ "nodev" ];

            users.users.nixos.initialHashedPassword = mkForce "$y$j9T$w.lPI/qMkKd7GU.8pBU.L1$ykS3e6w4FX1MF6f12mfjNkXDBScP75/jNyEjNH68bS8";

            programs.neovim = {
                enable = true;
                defaultEditor = true;
            };

            nix.settings.experimental-features = [
                "nix-command"
                "flakes"
            ];

            # Useful packages for installation and recovery
            environment.systemPackages = with pkgs; [
                btrfs-progs
                curl
                git
                parted
                local.installer
            ];

            # Increase size of tmpfs on /run
            boot.runSize = "50%";

            # Allow easy connection to Wi-Fi (wpa_supplicant sucks)
            networking = {
                networkmanager.enable = true;
                wireless.enable = mkForce false;
            };

            # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
            system.stateVersion = "23.11";
        };
}
