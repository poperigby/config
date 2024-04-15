{ inputs, ... }:

{
    imports = [
        ../../modules/nixos
        ./drives.nix
        ./home.nix
    ];

    # Define hostname
    networking.hostName = "allan";

    # Enable PipeWire
    modules.nixos.audio.enable = true;

    # Enable backups
    modules.nixos.backups = {
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

    # DO NOT TOUCH 💀
    system.stateVersion = "23.11";
}
