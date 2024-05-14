{ ... }:

{
    imports = [
        ./drives.nix
        ./home.nix
    ];

    # Define hostname
    networking.hostName = "allan";

    # Enable PipeWire
    common.os.audio.enable = true;

    # Automatic location provider (for gammastep)
    common.os.location.enable = true;

    # Enable backups
    common.os.backups = {
        enable = true;
        paths = [
            "/home/*/.local/share"
        ];
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

    # Enable Bluetooth
    hardware.bluetooth.enable = true;

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

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    system.stateVersion = "23.11";
}
