{ ... }:

{
    imports = [
        ../../common/os
        ./drives.nix
        ./gaming.nix
        ./home.nix
    ];

    # Define hostname
    networking.hostName = "snowy";

    # Enable PipeWire
    common.os.audio.enable = true;

    # Enable backups
    common.os.backups = {
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
