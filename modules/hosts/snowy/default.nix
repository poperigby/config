{
    den,
    lib,
    inputs,
    ...
}:
{
    flake-file.inputs = {
        cosmic-manager = {
            url = "github:HeitorAugustoLN/cosmic-manager";
            inputs = {
                nixpkgs.follows = "nixpkgs";
                home-manager.follows = "home-manager";
            };
        };
        nix-flatpak.url = "github:gmodena/nix-flatpak";
    };

    den.aspects.snowy = {
        includes = [
            den.aspects.common
            den.aspects.gui
            den.aspects.gaming

            (den.aspects.system._.boot { })
            den.aspects.desktops._.cosmic

            den.aspects.hardware._.android
            den.aspects.hardware._.audio
            den.aspects.hardware._.bluetooth
            den.aspects.hardware._.corsair
            den.aspects.hardware._.printing
            den.aspects.hardware._.scanning

            (den.aspects.services._.backups {
                paths =
                    let
                        cassidy = "/home/cassidy";
                    in
                    [
                        "/home/*/.local/state/backups"
                        # Modding setups
                        "${cassidy}/Games/Modding"
                    ];
                exclude =
                    let
                        cassidy = "/home/cassidy";
                    in
                    [
                        "${cassidy}/Games/Modding/Games/*/_download/"
                    ];
            })
            den.aspects.services._.earlyoom
            den.aspects.services._.geolocation
            den.aspects.services._.virtualization
            den.aspects.services._.virt-manager
        ];

        _.to-users.includes = [ den._.define-user ];

        nixos = {
            time.timeZone = "America/Los_Angeles";

            networking.networkmanager.enable = true;

            services.lact.enable = true;
            services.flatpak.enable = true;

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

            virtualisation.docker.enable = true;

            # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
            system.stateVersion = "23.11";
        };

        provides.cassidy = {
            includes = [
                den.aspects.common._.user
                den.aspects.gui._.user
                den.aspects.gaming._.bethesda-user

                den.aspects.programs._.thunderbird

                (den.aspects.services._.ludusavi-config {
                    settings = {
                        manifest.url = "https://raw.githubusercontent.com/mtkennerly/ludusavi-manifest/master/data/manifest.yaml";
                        roots = [
                            {
                                path = "~/.local/share/Steam";
                                store = "steam";
                            }
                            {
                                path = "~/.config/heroic";
                                store = "heroic";
                            }
                            {
                                path = "/mnt/ssd0/SteamLibrary";
                                store = "steam";
                            }
                            {
                                path = "/mnt/hdd0/SteamLibrary";
                                store = "steam";
                            }
                        ];
                        customGames = [
                            {
                                name = "OpenMW";
                                files = [ "~/.local/share/openmw/saves" ];
                            }
                            {
                                name = "GZDoom";
                                files = [ "~/.config/gzdoom/savegames" ];
                            }
                        ];
                        backup.path = "~/.local/state/backups/ludusavi";
                        restore.path = "~/.local/state/backups/ludusavi";
                    };
                })
            ];

            homeManager =
                { pkgs, ... }:
                {
                    imports = [
                        inputs.cosmic-manager.homeManagerModules.cosmic-manager
                        inputs.nix-flatpak.homeManagerModules.nix-flatpak
                    ];

                    wayland.desktopManager.cosmic.enable = true;
                    programs.cosmic-ext-calculator.enable = true;

                    services.flatpak = {
                        enable = true;
                        uninstallUnmanaged = true;
                        packages = [
                            rec {
                                appId = "com.hypixel.HytaleLauncher";
                                sha256 = "sha256-pMZyFtwlGTvCcClvK/dr42+Kvv6ZPhRCgH3iGTgxxHI=";
                                bundle = "${pkgs.fetchurl {
                                    url = "https://launcher.hytale.com/builds/release/linux/amd64/hytale-launcher-latest.flatpak";
                                    inherit sha256;
                                }}";
                            }
                        ];
                    };

                    home.packages = with pkgs; [
                        er-patcher
                        graphite
                        pkgsRocm.blender
                        r2modman
                    ];

                    home.file.morrowindBlenderPlugin = {
                        source = pkgs.fetchFromGitHub {
                            owner = "Greatness7";
                            repo = "io_scene_mw";
                            rev = "0.8.103";
                            hash = "sha256-f1PgjSs6jU99oqEJgOwb/wX8gVW+2DNgS+kkeka/Mo0=";
                        };
                        target = ".config/blender/4.3/scripts/addons/io_scene_mw";
                        recursive = true;
                    };
                };
        };
    };
}
