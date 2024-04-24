{ ... }:

{
    imports = [
        ../../common/os
        ./drives.nix
        ./gaming.nix
        ./hardware.nix
        ./home.nix
    ];

    # Define hostname
    networking.hostName = "snowy";

    # Enable PipeWire
    common.os.audio.enable = true;

    # Automatic location provider (for gammastep)
    common.os.location.enable = true;

    # Enable backups
    common.os.backups = {
        enable = true;
        paths = [
            "/home/*/.local/share"
        ];
    };

    # Set time zone.
    time.timeZone = "America/Los_Angeles";

    # Having SSHD enabled is pretty handy sometimes
    services.openssh.enable = true;
}
