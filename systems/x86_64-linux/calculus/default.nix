{ ... }:

{
    imports = [
        ./drives.nix
        ./hardware.nix
    ];

    custom = {
        hardware = {
            audio.enable = true;
        };
        services = {
            earlyoom.enable = true;
        };
        suites = {
            common.enable = true;
            gaming.enable = true;
            gui.enable = true;
        };
        desktops.gnome.enable = true;
        users.shane.enable = true;
    };

    services = {
        openssh.enable = true;
    };

    time.timeZone = "America/Los_Angeles";

    networking.networkmanager.enable = true;

    # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
    system.stateVersion = "23.11";
}
