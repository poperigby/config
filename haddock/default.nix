# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

{
    imports = [
        ../common.nix
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
        inputs.nh.packages."${pkgs.system}".default
        inputs.manix.packages."${pkgs.system}".manix
    ];

    services = {
        openssh.enable = true;
    };

    # DO NOT TOUCH
    system.stateVersion = "23.11";
}
