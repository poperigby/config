# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

{
    imports = [
        ../../common
        ./services
        ./hardware-configuration.nix
    ];

    config.common.backups.paths = [
        "/home/*/.local/share"
    ];

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
        inputs.manix.packages."${pkgs.system}".manix
    ];

    services = {
        openssh.enable = true;
    };

    # DO NOT TOUCH
    system.stateVersion = "23.11";
}
