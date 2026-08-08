{
    den,
    inputs,
    ...
}:
{
    flake-file.inputs = {
        crowdsec.url = "github:TornaxO7/nixpkgs/crowdsec";
        flux = {
            url = "github:IogaMaster/flux";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nix-minecraft = {
            url = "github:Infinidoge/nix-minecraft";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        vpn-confinement.url = "github:Maroka-chan/VPN-Confinement";
        nix = {
            url = "github:NixOS/nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    den.aspects.haddock = {
        includes = with den.aspects; [
            (services._.backups {
                paths = [
                    "/home"
                    "/var/lib/bazarr"
                    "/var/lib/continuwuity"
                    "/var/lib/immich"
                    "/var/lib/jellyfin"
                    "/var/lib/lidarr"
                    "/var/lib/lldap"
                    "/var/lib/mealie"
                    "/var/lib/minecraft/*/world"
                    "/var/lib/moonfire-nvr"
                    "/var/lib/paperless"
                    "/var/lib/private/prowlarr"
                    "/var/lib/qBittorrent"
                    "/var/lib/radarr"
                    "/var/lib/readarr"
                    "/var/lib/rustical"
                    "/var/lib/sonarr"
                    "/var/lib/trilium"
                    "/var/lib/vikunja"
                ];
            })
        ];

        provides.to-users.includes = with den.aspects; [
            # Profiles
            common

            # System
            (system._.boot { })

            # Services
            services._.postfix
            services._.smartd

            # CLI
            programs._.bat
            programs._.bottom
            programs._.direnv
            programs._.fish
            programs._.git
            programs._.gpg
            programs._.jujutsu
            programs._.neovim
            programs._.starship
            programs._.tealdeer
            programs._.television
            programs._.yazi

            # Development services
            services._.lspmux
        ];

        nixos =
            {
                lib,
                pkgs,
                ...
            }:
            {
                imports = [
                    (inputs.import-tree ./_services)
                    (inputs.crowdsec.outPath + "/nixos/modules/services/security/crowdsec-firewall-bouncer.nix")
                    (inputs.crowdsec.outPath + "/nixos/modules/services/security/crowdsec.nix")
                    inputs.flux.nixosModules.default
                    inputs.nix-minecraft.nixosModules.minecraft-servers
                    inputs.vpn-confinement.nixosModules.default
                ];

                disabledModules = [
                    "services/security/crowdsec-firewall-bouncer.nix"
                    "services/security/crowdsec.nix"
                ];

                nixpkgs.overlays = [ inputs.flux.overlays.default ];
                flux.enable = true;

                environment.systemPackages = with pkgs; [
                    lynis
                ];

                time.timeZone = "America/Los_Angeles";

                services = {
                    redis.servers.haddock.enable = true;
                    caddy.virtualHosts."print.haddock.cc".extraConfig = ''
                        import auth
                        reverse_proxy http://192.168.1.27:5000
                    '';
                    openssh = {
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
                            # AllowTcpForwarding = false;
                            PermitTunnel = false;
                        };
                        extraConfig = ''
                            Match Address 192.168.1.0/24
                                PasswordAuthentication yes  
                        '';
                    };
                };

                # Required to allow local password authentication
                # https://github.com/NixOS/nixpkgs/issues/12867
                security.pam.services.sshd.unixAuth = lib.mkForce true;

                networking.useNetworkd = true;

                # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
                system.stateVersion = "23.11";
            };

        provides.cassidy = {
            includes = [
                den.aspects.cassidy-accounts
                den.aspects.programs._.atuin
            ];

            homeManager =
                { pkgs, ... }:
                {
                    home.packages = with pkgs; [
                        custom.find-open-ports
                        osc
                    ];
                };
        };
    };
}
