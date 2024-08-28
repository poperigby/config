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
                    "/var/backup"
                    "/var/lib/jellyfin"
                    "/var/lib/lldap"
                    "/var/lib/mealie"
                    "/var/lib/nextcloud"
                    "/var/lib/paperless"
                    "/var/lib/prowlarr"
                    "/var/lib/radarr"
                    "/var/lib/readarr"
                    "/var/lib/readarr"
                    "/var/lib/sonarr"
                    "/var/lib/vikunja"
                ];
            };
            postfix.enable = true;
        };
        suites = {
            common.enable = true;
        };
    };

    time.timeZone = "America/Los_Angeles";

    services.openssh.enable = true;

    networking.useDHCP = true;

    # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
    system.stateVersion = "23.11";
}
