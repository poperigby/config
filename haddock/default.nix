# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

{
    imports = [
        ../common
        ./hardware-configuration.nix
    ];

    # Define hostname
    networking.hostName = "haddock"; 

    # Set time zone.
    time.timeZone = "America/Los_Angeles";

    # Define a user account. Don't forget to set a password with 'passwd'.
    users.users.cassidy = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
    };

    environment.systemPackages = with pkgs; [
        git
        neovim
        just
        podman
        nixpkgs-fmt
        sops
        inputs.nh.packages."${pkgs.system}".default
        inputs.manix.packages."${pkgs.system}".manix
    ];

    services = {
        openssh.enable = true;
    };

    # Backups
    sops.secrets = {
        "haddock/restic/url" = {};
        "haddock/restic/password" = {};
    };
    services.restic.backups = {
        borgbase = {
            repositoryFile = config.sops.secrets."haddock/restic/url".path;
            passwordFile = config.sops.secrets."haddock/restic/password".path;
            timerConfig.OnCalendar = "daily";
            paths = [
                "/home/*/.local/share"
            ];
            pruneOpts = [
                "--keep-daily 7"
                "--keep-weekly 4"
                "--keep-monthly 3"
                "--keep-yearly 1"
            ];
        };
    };

    # DO NOT TOUCH
    system.stateVersion = "23.11";
}
