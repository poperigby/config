{ config, pkgs, inputs, ... }:

{
    imports = [
        ./ld.nix
        ./secrets.nix
        ./backups.nix
    ];

    # Enable New CLI and Flakes
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # Select internationalization properties.
    i18n.defaultLocale = "en_US.UTF-8";

    # Dynamically populates contents of /bin and /usr/bin/, allowing
    # programs that assume FHS to work.
    services.envfs.enable = true;

    # Specifies where my flake is located
    environment.sessionVariables.FLAKE = "/home/cassidy/nixos";

    # Set neovim as my default editor
    environment.variables.EDITOR = "nvim";

    # Set up me :)
    sops.secrets."common/passwords/cassidy".neededForUsers = true;
    users.users.cassidy = {
        isNormalUser = true;
        hashedPasswordFile = config.sops.secrets."common/passwords/cassidy".path;
        extraGroups = [ "wheel" ];
    };

    # Boot loader configuration
    boot.loader = {
        systemd-boot = {
            enable = true;
            # Limit the number of generations to keep
            configurationLimit = 10;
        };
        efi.canTouchEfiVariables = true;
    };


    # Perform garbage collection weekly to maintain low disk usage
    nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 1w";
    };

    # Optimize storage
    nix.settings.auto-optimise-store = true;
}
