{ ... }:

{
    imports = [
        ../../modules/os
        ./drives.nix
        ./hardware.nix
        ./home.nix
        ./services
    ];

    # Define hostname
    networking.hostName = "haddock";

    # Setup Restic backups
    modules.os.backups = {
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
