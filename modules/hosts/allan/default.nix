{ den, ... }:
{
    den.aspects.allan = {
        provides.to-users.includes = with den.aspects; [
            # Profiles
            common
            gui

            # Desktop
            desktops._.cosmic

            # System
            (system._.boot { secureBoot = true; })
            (services._.backups { paths = [ ]; })
            (services._.illuminanced {
                settings = {
                    daemonize = {
                        log_to = "syslog";
                        pid_file = "/run/illuminanced.pid";
                        log_level = "ERROR";
                    };
                    general = {
                        check_period_in_seconds = 1;
                        light_steps = 10;
                        min_backlight = 70;
                        step_barrier = 0.1;
                        event_device_mask = "/dev/input/event*";
                        event_device_name = "Asus WMI hotkeys";
                        backlight_file = "/sys/class/backlight/intel_backlight/brightness";
                        max_backlight_file = "/sys/class/backlight/intel_backlight/max_brightness";
                        illuminance_file = "/sys/bus/iio/devices/iio:device0/in_illuminance_raw";
                        enable_max_brightness_mode = true;
                        filename_for_sensor_activation = "";
                    };
                    kalman = {
                        q = 1;
                        r = 20;
                        covariance = 10;
                    };
                    light = {
                        points_count = 6;
                        illuminance_0 = 0;
                        light_0 = 0;
                        illuminance_1 = 20;
                        light_1 = 1;
                        illuminance_2 = 300;
                        light_2 = 3;
                        illuminance_3 = 700;
                        light_3 = 4;
                        illuminance_4 = 1100;
                        light_4 = 5;
                        illuminance_5 = 7100;
                        light_5 = 10;
                    };
                };
            })

            # Hardware
            hardware._.android
            hardware._.audio
            hardware._.bluetooth
            hardware._.printing
            hardware._.scanning

            # Services
            services._.geolocation
            services._.smartd

            # CLI
            programs._.atuin
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

            # GUI apps
            programs._.discord
            programs._.element-desktop
            programs._.firefox
            programs._.mpv
            programs._.wezterm
            programs._.bottom-gui
            programs._.neovim-gui
            programs._.yazi-gui
        ];

        nixos = {
            # Enable NetworkManager
            networking.networkmanager.enable = true;

            # Roaming friendly time synchronization daemon
            services.ntpd-rs.enable = true;

            # Automatically change timezone based on location
            services.automatic-timezoned.enable = true;

            virtualisation.docker.enable = true;

            # Power saving
            services.thermald.enable = true;
            # services.auto-cpufreq = {
            #   enable = true;
            #   settings = {
            #     battery = {
            #       governor = "powersave";
            #       turbo = "never";
            #     };
            #     charger = {
            #       governor = "performance";
            #       turbo = "auto";
            #     };
            #   };
            # };

            # Firmware updating
            services.fwupd = {
                enable = true;
                # Required to get firmware updates for Intel CPUs
                extraRemotes = [ "lvfs-testing" ];
            };

            boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

            # System state version
            system.stateVersion = "23.11";
        };

        provides.cassidy = {
            includes = [ den.aspects.programs._.thunderbird ];

            homeManager =
                { pkgs, ... }:
                {
                    home.packages = with pkgs; [
                        kdePackages.kdenlive
                        openmw
                    ];
                };
        };
    };
}
