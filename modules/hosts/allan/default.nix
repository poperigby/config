{ ... }:

{
    den.aspects.allan = {
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
        };
    };
    # custom = {
    #     hardware = {
    #         android.enable = true;
    #         audio.enable = true;
    #         bluetooth.enable = true;
    #         printing.enable = true;
    #         scanning.enable = true;
    #     };
    #
    #     services = {
    #         backups = {
    #             enable = true;
    #             paths = [ ];
    #         };
    #
    #         geolocation.enable = true;
    #
    #         illuminanced = {
    #             enable = true;
    #             settings = {
    #                 daemonize = {
    #                     log_to = "syslog";
    #                     pid_file = "/run/illuminanced.pid";
    #                     log_level = "ERROR";
    #                 };
    #                 general = {
    #                     check_period_in_seconds = 1;
    #                     light_steps = 10;
    #                     min_backlight = 70;
    #                     step_barrier = 0.1;
    #                     event_device_mask = "/dev/input/event*";
    #                     event_device_name = "Asus WMI hotkeys";
    #                     backlight_file = "/sys/class/backlight/intel_backlight/brightness";
    #                     max_backlight_file = "/sys/class/backlight/intel_backlight/max_brightness";
    #                     illuminance_file = "/sys/bus/iio/devices/iio:device0/in_illuminance_raw";
    #                     enable_max_brightness_mode = true;
    #                     filename_for_sensor_activation = "";
    #                 };
    #                 kalman = {
    #                     q = 1;
    #                     r = 20;
    #                     covariance = 10;
    #                 };
    #                 light = {
    #                     points_count = 6;
    #                     illuminance_0 = 0;
    #                     light_0 = 0;
    #                     illuminance_1 = 20;
    #                     light_1 = 1;
    #                     illuminance_2 = 300;
    #                     light_2 = 3;
    #                     illuminance_3 = 700;
    #                     light_3 = 4;
    #                     illuminance_4 = 1100;
    #                     light_4 = 5;
    #                     illuminance_5 = 7100;
    #                     light_5 = 10;
    #                 };
    #             };
    #         };
    #     };
    #
    #     suites = {
    #         common.enable = true;
    #         gui.enable = true;
    #     };
    #
    #     desktops.cosmic.enable = true;
    #     system.boot.secureBoot = true;
    #     users.cassidy.enable = true;
    # };
}
