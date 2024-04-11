{ inputs, ... }:

{
    imports = [
        ../../modules/nixos
        ./drives.nix
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

    # Enable KDE Plasma
    modules.nixos.plasma.enable = true;
}
