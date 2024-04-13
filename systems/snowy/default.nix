{ inputs, ... }:

{
    imports = [
        ../../modules/nixos
        ./drives.nix
        ./gaming.nix
    ];

    home-manager = {
        extraSpecialArgs = { inherit inputs; };
        users.cassidy = import ../../modules/home;
    };

    # Define hostname
    networking.hostName = "snowy";

    # Enable backups
    modules.nixos.backups = {
        enable = true;
        paths = [
            "/home/*/.local/share"
        ];
    };

    modules.nixos.gaming.enable = true;

    # Set time zone.
    time.timeZone = "America/Los_Angeles";

    # Enable KDE Plasma
    modules.nixos.plasma.enable = true;

    # DO NOT TOUCH 💀
    system.stateVersion = "23.11";
}
