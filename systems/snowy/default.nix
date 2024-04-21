{ ... }:

{
    imports = [
        ../../modules/os
        ./drives.nix
        ./gaming.nix
        ./hardware.nix
        ./home.nix
    ];

    # Define hostname
    networking.hostName = "snowy";

    # Enable PipeWire
    modules.os.audio.enable = true;

    # Enable backups
    modules.os.backups = {
        enable = true;
        paths = [
            "/home/*/.local/share"
        ];
    };

    # Set time zone.
    time.timeZone = "America/Los_Angeles";
}
