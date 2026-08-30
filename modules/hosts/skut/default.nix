{ den, ... }:

{
    den.aspects.skut = {
        includes = [
            (den.batteries.tty-autologin "nixos")
            den.aspects.programs._.nix
            den.aspects.system._.boot
        ];

        nixos =
            {
                pkgs,
                modulesPath,
                ...
            }:
            {
                imports = [
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

                services.openssh.settings = {
                    PasswordAuthentication = true;
                    PermitEmptyPasswords = true;
                };

                programs.neovim = {
                    enable = true;
                    defaultEditor = true;
                };

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
            };
    };
}
