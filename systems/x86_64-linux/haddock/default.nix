{ ... }:

{
    imports = [
        ./drives.nix
        ./hardware.nix
        ./home.nix
        ./services
    ];

    # Define hostname
    networking.hostName = "haddock";

    poperigby = {
        services = {
            backups = {
                enable = true;
                paths = [
                    "/home/*/.local/share"
                    "/var/lib/*"
                    "/var/backup/*"
                ];
            };
        };
        suites = {
            common.enable = true;
        };
    };

    # Set time zone.
    time.timeZone = "America/Los_Angeles";

    services.openssh.enable = true;

    # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
    system.stateVersion = "23.11";
}
