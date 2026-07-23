{ den, inputs, ... }:

{
    flake-file.inputs = {
        hushmic.url = "github:crowquillx/hushmic-nix";
        nix-flatpak.url = "github:gmodena/nix-flatpak";
    };

    den.aspects.snowy = {
        provides.to-users.includes = with den.aspects; [
            # Profiles
            common
            gui
            gaming

            # Desktop
            (desktops._.niri { hostConfig = ./niri.kdl; })
            (programs._.dms {
                settings = {
                    activeDisplayProfile = { };
                    displayProfiles = { };
                    displayProfileAutoSelect = false;
                    niriOutputSettings = {
                        "DP-3" = { };
                    };
                    screenPreferences.wallpaper = [ "all" ];
                    showBattery = true;
                    showGpuTemp = true;
                    systemMonitorShowGpuTemp = true;
                    systemMonitorGpuPciId = "";
                    enabledGpuPciIds = [ ];
                    selectedGpuIndex = 0;
                    matugenTargetMonitor = "";
                    lockScreenActiveMonitor = "all";
                };
            })

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
            services._.smartd

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
            gaming._.morrowind
            services._.joystickwake
            (services._.ludusavi {
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

        nixos =
            { lib, ... }:
            {
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

                services.postgresql = {
                    enable = true;
                    ensureUsers = [
                        {
                            name = "cassidy";
                            ensureClauses.superuser = true;
                        }
                        {
                            name = "root";
                            ensureClauses.superuser = true;
                        }
                    ];
                    authentication = lib.mkForce ''
                        # TYPE  DATABASE        USER            ADDRESS                 METHOD
                        local   all             all                                     peer
                        host    all             all             127.0.0.1/32            trust
                        host    all             all             ::1/128                 trust
                    '';
                };

                # For installing Nestor configuration to SD card
                boot.binfmt = {
                    emulatedSystems = [ "aarch64-linux" ];
                    preferStaticEmulators = true;
                };
                nix.settings.extra-platforms = [ "aarch64-linux" ];

                # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
                system.stateVersion = "23.11";
            };

        provides.cassidy = {
            includes = [ den.aspects.cassidy-accounts ];

            homeManager =
                {
                    inputs',
                    pkgs,
                    ...
                }:
                {
                    imports = [ inputs.nix-flatpak.homeManagerModules.nix-flatpak ];

                    xdg.autostart = {
                        enable = true;
                        entries = with pkgs; [
                            "${ckb-next}/share/applications/ckb-next.desktop"
                            "${signal-desktop}/share/applications/signal.desktop"
                            "${steam}/share/applications/steam.desktop"
                        ];
                    };

                    services.flatpak = {
                        enable = true;
                        uninstallUnmanaged = true;
                        packages = [
                            "com.usebottles.bottles"
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
                            hushmic = pkgs.callPackage "${inputs.hushmic}/package.nix" {
                                xorg = {
                                    libX11 = pkgs.libx11;
                                    libXcursor = pkgs.libxcursor;
                                    libXi = pkgs.libxi;
                                    libXrandr = pkgs.libxrandr;
                                    libxcb = pkgs.libxcb;
                                };
                            };
                        in
                        {
                            packages =
                                with pkgs;
                                [
                                    er-patcher
                                    dbeaver-bin
                                    graphite
                                ]
                                ++ [
                                    blender
                                    hushmic
                                ];
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
    };
}
