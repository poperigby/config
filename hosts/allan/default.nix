{ ... }:

{
    imports = [
        ../../common
        ./disks.nix
    ];

    # Define hostname
    networking.hostName = "allan";

    # Roaming friendly time synchronization daemon
    services.chrony = {
        enable = true;
        enableNTS = true;
        servers = [ "time.cloudflare.com" ];
    };

    # Enable fingerprint reader
    services.fprintd.enable = true;
}
