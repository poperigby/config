{ ... }:

{
    imports = [
        ../../common
        ./disk-config.nix
    ];

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
