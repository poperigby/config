{ pkgs, inputs, ... }:

{
    imports = [
        ../../modules/nixos
        ./drives.nix
        ./hardware.nix
        ./services
    ];

    home-manager = {
        extraSpecialArgs = { inherit inputs; };
        users.cassidy = import ../../modules/home;
    };

    # Define hostname
    networking.hostName = "haddock";

    # Setup Restic backups
    modules.nixos.backups = {
        enable = true;
        paths = [
            "/home/*/.local/share"
            "/var/lib/*"
            "/var/backup/*"
        ];
    };

    # Set time zone.
    time.timeZone = "America/Los_Angeles";

    environment.systemPackages = with pkgs; [
        neovim
    ];

    services.openssh.enable = true;

    # DO NOT TOUCH 💀
    system.stateVersion = "23.11";
}
