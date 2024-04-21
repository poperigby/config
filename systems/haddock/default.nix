{ ... }:

{
    imports = [
        ../../common/os
        ./drives.nix
        ./hardware.nix
        ./home.nix
        ./services
    ];

    # Define hostname
    networking.hostName = "haddock";

    # Setup Restic backups
    common.os.backups = {
        enable = true;
        paths = [
            "/home/*/.local/share"
            "/var/lib/*"
            "/var/backup/*"
        ];
    };

    # Set time zone.
    time.timeZone = "America/Los_Angeles";

    services.openssh.enable = true;
}
