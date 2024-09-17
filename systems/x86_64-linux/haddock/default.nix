{ pkgs, ... }:

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
                    "/var/lib/radicale"
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

    environment.systemPackages = with pkgs; [
        lynis
    ];

    time.timeZone = "America/Los_Angeles";

    services.openssh = {
        enable = true;
        settings = {
            # https://www.digitalocean.com/community/tutorials/how-to-harden-openssh-on-ubuntu-20-04
            PermitRootLogin = "no";
            MaxAuthTries = 3;
            PasswordAuthentication = false;
            PermitEmptyPasswords = false;
            ChallengeResponseAuthentication = false;
            PermitUserEnvironment = false;
            AllowAgentForwarding = false;
            AllowTcpForwarding = false;
            PermitTunnel = false;
        };
    };

    networking.useDHCP = true;

    # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
    system.stateVersion = "23.11";
}
