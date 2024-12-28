{ lib, pkgs, ... }:

{
    # Set password for root user
    users.users.nixos.password = "nixos"; # TODO: Should this be an actual good password?

    # Setup neovim
    programs.neovim = {
        enable = true;
        defaultEditor = true;
    };

    # Enable New CLI and Flakes
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # Useful packages for installation and recovery
    environment.systemPackages = with pkgs; [
        btrfs-progs
        curl
        git
        parted
        custom.installer
    ];

    # Allows easy connection to Wi-Fi
    networking.networkmanager.enable = true;

    # wpa_supplicant sucks
    networking.wireless.enable = lib.mkForce false;

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    system.stateVersion = "23.11";
}
