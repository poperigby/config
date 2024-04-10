{ ... }:

{
    imports = [
        ../../common
        ./drives.nix
    ];

    # Define hostname
    networking.hostName = "allan";

    # Enable NetworkManager
    networking.networkmanager.enable = true;

    # Enable backups
    common.backups = {
        enable = true;
        paths = [
            "/home/*/.local/share"
        ];
    };

    # Enable KDE Plasma
    common.plasma.enable = true;

    # Roaming friendly time synchronization daemon
    services.chrony = {
        enable = true;
        enableNTS = true;
        servers = [ "time.cloudflare.com" ];
    };

    # Enable fingerprint reader
    services.fprintd.enable = true;

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
}
