{ ... }:

{
    imports = [
        ./drives.nix
    ];

    poperigby = {
        hardware = {
            audio.enable = true;
            bluetooth.enable = true;
            printing.enable = true;
            scanning.enable = true;
        };
        services = {
            backups = {
                enable = true;
                paths = [
                    "/home/*/.local/share"
                ];
            };
            geolocation.enable = true;
        };
        suites = {
            common.enable = true;
            gui.enable = true;
        };
    };

    # Enable NetworkManager
    networking.networkmanager.enable = true;

    # Roaming friendly time synchronization daemon
    services.chrony = {
        enable = true;
        enableNTS = true;
        servers = [ "time.cloudflare.com" ];
    };

    # Automatically change timezone based on location
    services.automatic-timezoned.enable = true;

    # Power saving
    services.thermald.enable = true;
    services.auto-cpufreq = {
        enable = true;
        settings = {
          battery = {
             governor = "powersave";
             turbo = "never";
          };
          charger = {
             governor = "performance";
             turbo = "auto";
          };
        };
    };

    # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
    system.stateVersion = "23.11";
}
