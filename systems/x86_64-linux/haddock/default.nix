{ ... }:

{
    imports = [
        ./drives.nix
        ./hardware.nix
        ./services
    ];

    poperigby = {
        services = {
            backups = {
                enable = true;
                paths = [
                    # TODO: Do I need to backup all of /var/lib?
                    "/var/lib/*"
                    "/var/backup/*"
                ];
            };
            smartd.mail = {
                enable = true;
                senderDomain = "haddock.cc";
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
