{ lib, ... }:

{
    imports = [
        ./drives.nix
        ./hardware.nix
    ] ++ lib.poperigby.getValidFiles ./services;

    poperigby = {
        services = {
            backups = {
                enable = true;
                paths = [
                    "/var/backup/*"
                    "/var/lib/jellyfin/*"
                    "/var/lib/lldap/*"
                    "/var/lib/mealie/*"
                    "/var/lib/nextcloud/*"
                    "/var/lib/private/prowlarr/*"
                    "/var/lib/private/uptime-kuma/*"
                    "/var/lib/radarr/*"
                    "/var/lib/sonarr/*"
                ];
            };
            postfix.enable = true;
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
