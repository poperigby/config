{ den, ... }:
{

    den.aspects.allan = {
        provides.to-users.includes = with den.aspects; [
            # Profiles
            common

            # Desktop
            (desktops._.niri {
                wallpaper = ./wallpaper.jpg;
            })

            # System
            (system._.boot { secureBoot = true; })
            (services._.backups { paths = [ ]; })

            # Hardware
            hardware._.android
            hardware._.audio
            hardware._.bluetooth
            hardware._.printing
            hardware._.scanning

            # Services
            services._.cache
            services._.geolocation
            services._.smartd

            # Development services
            services._.lspmux

            # GUI apps
            programs._.discord
            programs._.element-desktop
            programs._.firefox
            programs._.mpv
            programs._.steam
            programs._.wezterm
        ];

        nixos = {
            networking.networkmanager.enable = true;

            services = {
                # Roaming friendly time synchronization daemon
                ntpd-rs = {
                    enable = true;
                    settings.source-defaults.initial-poll-interval = 0;
                };
                automatic-timezoned.enable = true;
                fprintd.enable = true;
                thermald.enable = true;
                fwupd = {
                    enable = true;
                    # Required to get firmware updates for Intel CPUs
                    extraRemotes = [ "lvfs-testing" ];
                };
            };

            system.stateVersion = "23.11";
        };

        provides.cassidy = {
            includes = [
                den.aspects.cassidy-accounts
                den.aspects.programs._.thunderbird
            ];

            homeManager =
                { lib, pkgs, ... }:
                {
                    wayland.windowManager.niri.settings.input.touchpad = {
                        tap = { };
                        natural-scroll = { };
                    };

                    programs.noctalia.settings.hooks =
                        let
                            power = lib.getExe pkgs.power-profiles-daemon;
                        in
                        {
                            battery_charging = "${power} set performance";
                            battery_discharging = "${power} set power-saver";
                        };

                    home.packages = with pkgs; [
                        kdePackages.kdenlive
                        prusa-slicer
                    ];
                };
        };
    };
}
