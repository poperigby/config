{ ... }:

{
    imports = [
        ./audio.nix
        ./backups.nix
        ./bootloader.nix
        ./gaming.nix
        ./home.nix
        ./ld.nix
        ./location.nix
        ./qbittorrent.nix
        ./reduce-disk-usage.nix
        ./secrets.nix
        ./sudo.nix
        ./users.nix
    ];
    # Select internationalization properties.
    i18n.defaultLocale = "en_US.UTF-8";

    # Dynamically populates contents of /bin and /usr/bin, allowing
    # programs that assume FHS to work.
    services.envfs.enable = true;

    # Specifies where my flake is located for nh
    environment.sessionVariables.FLAKE = "/home/cassidy/nixos";

    # Enable zRAM swap
    zramSwap.enable = true;

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    system.stateVersion = "23.11";
}
