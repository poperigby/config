{
    den,
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
        provides.to-users.includes = with den.aspects; [
            # Profiles
            common
            gui
            gaming

            # Desktop
            desktops._.niri

            # System
            (system._.boot { })
            (services._.backups {
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

            # Hardware
            hardware._.android
            hardware._.iphone
            hardware._.audio
            hardware._.bluetooth
            hardware._.corsair
            hardware._.printing
            hardware._.scanning

            # Services
            services._.earlyoom
            services._.geolocation

            # Virtualization
            services._.virtualization
            services._.virt-manager

            # CLI
            programs._.atuin
            programs._.bat
            programs._.bottom
            programs._.direnv
            programs._.fish
            programs._.git
            programs._.gpg
            programs._.neovim
            programs._.starship
            programs._.tealdeer
            programs._.television
            programs._.yazi

            # Development services
            services._.lspmux

            # GUI apps
            programs._.bottom-gui
            programs._.discord
            programs._.element-desktop
            programs._.firefox
            programs._.mpv
            programs._.neovim-gui
            programs._.wezterm
            programs._.thunderbird
            programs._.yazi-gui

            # Gaming
            programs._.mangohud
            gaming._.bethesda-user
            services._.ludusavi
            services._.joystickwake
            (services._.ludusavi-config {
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

            services.pipewire.wireplumber.extraConfig = {
                "prefer-fifine-mic" = {
                    "monitor.alsa.rules" = [
                        {
                            matches = [
                                {
                                    "node.name" = "alsa_input.usb-FIFINE_Microphones_fifine_Microphone_REV1.0-00.pro-input-0";
                                }
                            ];
                            actions = {
                                update-props = {
                                    "priority.session" = 3000;
                                };
                            };
                        }
                    ];
                };
                "prefer-bluetooth-output" = {
                    "monitor.bluez.rules" = [
                        {
                            matches = [
                                {
                                    "node.name" = "matches:bluez_output.*";
                                }
                            ];
                            actions = {
                                update-props = {
                                    "priority.session" = 2000;
                                };
                            };
                        }
                    ];
                };
            };

            virtualisation.docker.enable = true;

            # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
            system.stateVersion = "23.11";
        };

        provides.cassidy.homeManager =
            { lib, pkgs, ... }:
            {
                imports = with inputs; [
                    nix-flatpak.homeManagerModules.nix-flatpak
                ];

                xdg.autostart = {
                    enable = true;
                    entries = with pkgs; [
                        "${ckb-next}/share/applications/ckb-next.desktop"
                        "${signal-desktop}/share/applications/signal.desktop"
                        "${steam}/share/applications/steam.desktop"
                    ];
                };

                xdg.configFile = {
                    "niri/config.kdl".text = lib.mkAfter ''
                        include "host.kdl"
                    '';
                    "niri/host.kdl".source = ./niri.kdl;
                };

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

                home =
                    let
                        blender = pkgs.pkgsRocm.blender;
                    in
                    {
                        packages =
                            with pkgs;
                            [
                                er-patcher
                                graphite
                            ]
                            ++ [ blender ];
                        file.morrowindBlenderPlugin = {
                            source = pkgs.fetchFromGitHub {
                                owner = "Greatness7";
                                repo = "io_scene_mw";
                                rev = "master";
                                hash = "sha256-P6xN9QPCsUl4xVAB57eI8Um0HAgPxwHQJiaYoKXKLQc=";
                            };
                            target = ".config/blender/${blender.version}/scripts/addons/io_scene_mw";
                            recursive = true;
                        };
                    };
            };
    };
}
