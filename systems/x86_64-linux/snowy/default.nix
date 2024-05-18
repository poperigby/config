{ ... }:

{
    imports = [
        ./drives.nix
        ./hardware.nix
    ];

    # Define hostname
    networking.hostName = "snowy";

    poperigby = {
        hardware = {
            audio.enable = true;
            bluetooth.enable = true;
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
            gaming = {
                enable = true;
                amd.enable = true;
            };
        };
    };

    # Set time zone.
    time.timeZone = "America/Los_Angeles";

    # Enable NetworkManager
    networking.networkmanager.enable = true;

    # TODO: Allow key-only auth
    # Having SSHD enabled is pretty handy sometimes
    services.openssh.enable = true;

    # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
    system.stateVersion = "23.11";
}
