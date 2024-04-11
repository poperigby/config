{ inputs, ... }:

{
    imports = [
        ../../modules/nixos
        ./drives.nix
    ];

    home-manager = {
        extraSpecialArgs = { inherit inputs; };
        users.cassidy = import ../../modules/home;
    };

    # Define hostname
    networking.hostName = "allan";

    # Enable NetworkManager
    networking.networkmanager.enable = true;

    # Enable backups
    modules.nixos.backups = {
        enable = true;
        paths = [
            "/home/*/.local/share"
        ];
    };

    # Enable KDE Plasma
    modules.nixos.plasma.enable = true;

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

    # DO NOT TOUCH 💀
    system.stateVersion = "23.11";
}
