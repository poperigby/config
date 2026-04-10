{
    den,
    inputs,
    lib,
    ...
}:
{
    den.aspects.haddock = {
        includes = [
            den.aspects.suites._.common
            (den.aspects.system._.boot { })

            (den.aspects.services._.backups {
                # Backup to Tintin as well as BorgBase
                repositories = {
                    borgbase = true;
                    tintin = true;
                };
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
            })
            den.aspects.services._.postfix
        ];

        _.to-users.includes = [ den._.define-user ];

        nixos =
            { lib, pkgs, ... }:
            {
            imports = [
                inputs.flux.nixosModules.default
                inputs.nix-minecraft.nixosModules.minecraft-servers
                (inputs.rustical.outPath + "/nixos/modules/services/networking/rustical.nix")
                inputs.vpn-confinement.nixosModules.default
                ./_nixos/drives.nix
                ./_nixos/hardware.nix
                ./_nixos/services
            ];

            nixpkgs.overlays = [ inputs.flux.overlays.default ];

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
        };

        provides.cassidy = {
            # Host already includes suites.common; keep host-specific user tweaks here.
            includes = [ den.aspects.suites._.common-user ];

            # For CrowdSec
            programs.fish.shellAliases.cs = "sudo cscli";

            homeManager = { pkgs, ... }: {
                home.packages = [
                    pkgs.custom.find-open-ports
                ];
            };
        };
    };
}
