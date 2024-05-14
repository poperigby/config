{ ... }:

{
    imports = [
        ./drives.nix
        ./gaming.nix
        ./hardware.nix
        ./home.nix
    ];

    # Define hostname
    networking.hostName = "snowy";

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

    # Set time zone.
    time.timeZone = "America/Los_Angeles";

    # Enable NetworkManager
    networking.networkmanager.enable = true;

    # Enable Bluetooth
    hardware.bluetooth.enable = true;

    # TODO: Allow key-only auth
    # Having SSHD enabled is pretty handy sometimes
    # services.openssh.enable = true;

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    system.stateVersion = "23.11";
}
