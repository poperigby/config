{ inputs, ... }:

{
    imports = [
        ../../modules/nixos
        ./drives.nix
        ./gaming.nix
        ./home.nix
    ];

    # Define hostname
    networking.hostName = "snowy";

    # Enable PipeWire
    modules.nixos.audio.enable = true;

    # Enable backups
    modules.nixos.backups = {
        enable = true;
        paths = [
            "/home/*/.local/share"
        ];
    };

    # Set time zone.
    time.timeZone = "America/Los_Angeles";

    # DO NOT TOUCH 💀
    system.stateVersion = "23.11";
}
