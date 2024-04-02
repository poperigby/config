# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ pkgs, inputs, ... }:

{
    imports = [
        ../../common
        ./disk-config.nix
        ./hardware.nix
        ./services
    ];

    # Setup Restic backups
    common.backups = {
        enable = true;
        paths = [
            "/home/*/.local/share"
            "/var/backup/postgresql"
            "/var/lib/lldap"
            "/var/lib/authelia-haddock"
        ];
    };

    # Define hostname
    networking.hostName = "haddock";

    # Set time zone.
    time.timeZone = "America/Los_Angeles";

    environment.systemPackages = with pkgs; [
        git
        neovim
        just
        podman
        nixpkgs-fmt
        sops
        inputs.nh.packages."${pkgs.system}".nh
    ];

    services = {
        openssh.enable = true;
    };

    # DO NOT TOUCH 💀
    system.stateVersion = "23.11";
}
