{ ... }:

{
    imports = [
        ./backups.nix
        ./bootloader.nix
        ./ld.nix
        ./reduce-disk-usage.nix
        ./secrets.nix
        ./users.nix
    ];

    # Enable New CLI and Flakes
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # Select internationalization properties.
    i18n.defaultLocale = "en_US.UTF-8";

    # Dynamically populates contents of /bin and /usr/bin, allowing
    # programs that assume FHS to work.
    services.envfs.enable = true;

    # Specifies where my flake is located for nh
    environment.sessionVariables.FLAKE = "/home/cassidy/nixos";

    # Set neovim as my default editor
    environment.variables.EDITOR = "nvim";

    # Enable zRAM swap
    zramSwap.enable = true;
}
