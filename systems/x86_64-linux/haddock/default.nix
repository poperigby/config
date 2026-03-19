{ lib, pkgs, ... }:

{
    imports = [
        ./drives.nix
        ./hardware.nix
        ./services
    ];

    custom = {
        services = {
            backups = {
                enable = true;
                # Backup to Tintin as well as BorgBase
                repositories.tintin = true;
                paths = [
                    "/var/lib/bazarr"
                    "/var/lib/immich"
                    "/var/lib/jellyfin"
                    "/var/lib/karakeep"
                    "/var/lib/lidarr"
                    "/var/lib/lldap"
                    "/var/lib/mealie"
                    "/var/lib/minecraft/*/world"
                    "/var/lib/moonfire-nvr"
                    "/var/lib/paperless"
                    "/var/lib/private/prowlarr"
                    "/var/lib/radarr"
                    "/var/lib/readarr"
                    "/var/lib/rustical"
                    "/var/lib/sonarr"
                    "/var/lib/trilium"
                    "/var/lib/vikunja"
                ];
            };
            postfix.enable = true;
        };
        suites = {
            common.enable = true;
        };
        users = {
            cassidy.enable = true;
            julian.enable = true;
            shane.enable = true;
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
        extraConfig = ''
            Match Address 192.168.1.0/24
                PasswordAuthentication yes  
        '';
    };

    # Required to allow local password authentication
    # https://github.com/NixOS/nixpkgs/issues/12867
    security.pam.services.sshd.unixAuth = lib.mkForce true;

    networking.useDHCP = true;

    # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
    system.stateVersion = "23.11";
}
