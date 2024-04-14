{ inputs, ... }:

{
    imports = [
        ../../modules/nixos
        ./drives.nix
        ./gaming.nix
    ];

    # Define hostname
    networking.hostName = "snowy";

    home-manager = {
        extraSpecialArgs = { inherit inputs; };
        users.cassidy = import ../../modules/home;
    };

    # Enable River WM
    modules.home.river.enable = true;

    # Enable PipeWire
    modules.nixos.audio.enable = true;

    # Enable backups
    modules.nixos.backups = {
        enable = true;
        paths = [
            "/home/*/.local/share"
        ];
    };

    # Set time zone.
    time.timeZone = "America/Los_Angeles";

    # DO NOT TOUCH 💀
    system.stateVersion = "23.11";
}
