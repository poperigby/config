{ pkgs, ... }:

{
    # Enable New CLI and Flakes
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # Select internationalization properties.
    i18n.defaultLocale = "en_US.UTF-8";

    # Allows running random binaries from the internet seamlessly
    programs.nix-ld = {
        enable = true;
        # Sets up common libraries to load
        libraries = with pkgs; [
            stdenv.cc.cc
            zlib
            fuse3
            icu
            zlib
            nss
            openssl
            curl
            expat
        ];
    };

    # Dynamically populates contents of /bin and /usr/bin/, allowing
    # programs that assume FHS to work.
    services.envfs.enable = true;

    # Specifies where my flake is located
    environment.sessionVariables.FLAKE = "/home/cassidy/nixos";

    # Use the systemd-boot EFI boot loader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # Limit the number of generations to keep
    boot.loader.systemd-boot.configurationLimit = 10;

    # Perform garbage collection weekly to maintain low disk usage
    nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 1w";
    };

    # Optimize storage
    nix.settings.auto-optimise-store = true;
}
