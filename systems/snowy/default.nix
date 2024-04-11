{ inputs, ... }:

{
    imports = [
        ../../common
        ./drives.nix
    ];

    home-manager = {
        extraSpecialArgs = { inherit inputs; };
        users.cassidy = import ../../home;
    };

    # Define hostname
    networking.hostName = "snowy";

    # Enable backups
    common.backups = {
        enable = true;
        paths = [
            "/home/*/.local/share"
        ];
    };

    # Enable KDE Plasma
    common.plasma.enable = true;
}
