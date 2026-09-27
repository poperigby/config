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
            gaming

            # Desktop
            (desktops._.niri {
                wallpaper = ./wallpaper.jpg;
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
            services._.cache
            services._.earlyoom
            services._.geolocation
            services._.smartd

            # Virtualization
            services._.virtualization
            services._.virt-manager

            # Development services
            services._.lspmux

            # GUI apps
            programs._.discord
            programs._.element-desktop
            programs._.firefox
            programs._.mpv
            programs._.wezterm
            programs._.thunderbird

            # Gaming
            gaming._.morrowind
            programs._.gpu-screen-recorder.niri
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

                services = {
                    flatpak.enable = true;
                    openssh.enable = true;
                    postgresql = {
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
                };

                programs.coolercontrol.enable = true;

                virtualisation.docker.enable = true;

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
                    lib,
                    osConfig,
                    pkgs,
                    ...
                }:
                let
                    inherit (lib) getExe;

                    hushmic = inputs'.hushmic.packages.default;
                    steam = osConfig.programs.steam.package;

                    hushmicAutostart = pkgs.local.modifyDesktopEntry {
                        package = hushmic;
                        desktopFile = "hushmic.desktop";
                        outputFile = "hushmic-autostart-tray.desktop";
                        replace.Exec = "${getExe hushmic} --tray";
                    };
                    signalAutostart = pkgs.local.modifyDesktopEntry {
                        package = pkgs.signal-desktop;
                        desktopFile = "signal.desktop";
                        outputFile = "signal-start-in-tray.desktop";
                        replace.Exec = "${getExe pkgs.signal-desktop} --start-in-tray %U";
                    };
                    steamAutostart = pkgs.local.modifyDesktopEntry {
                        package = steam;
                        desktopFile = "steam.desktop";
                        outputFile = "steam-silent-autostart.desktop";
                        replace.Exec = "${getExe steam} -silent";
                    };
                in
                {
                    imports = [ inputs.nix-flatpak.homeManagerModules.nix-flatpak ];

                    wayland.windowManager.niri.settings._children = [
                        {
                            output = {
                                _args = [ "GIGA-BYTE TECHNOLOGY CO., LTD. M27Q 21070B005868" ];
                                mode = "2560x1440@164.834";
                                variable-refresh-rate = { };
                            };
                        }
                    ];

                    xdg.autostart = {
                        enable = true;
                        entries =
                            let
                                inherit (lib.local.desktop) filePath' filePath;
                            in
                            (with pkgs; [
                                (filePath firefox)
                                (filePath' hushmicAutostart "hushmic-autostart-tray")
                                (filePath' signalAutostart "signal-start-in-tray")
                                (filePath' steamAutostart "steam-silent-autostart")
                            ]);
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
                        in
                        {
                            packages =
                                with pkgs;
                                [
                                    dbeaver-bin
                                    er-patcher
                                    graphite
                                    prusa-slicer
                                    qbittorrent
                                ]
                                ++ [
                                    blender
                                    hushmic
                                ];
                        };
                };

        };
    };
}
