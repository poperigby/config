{ lib, pkgs, ... }:

let
    inherit (lib) mkForce;
in
{
    users.users.nixos.initialHashedPassword = mkForce "$y$j9T$w.lPI/qMkKd7GU.8pBU.L1$ykS3e6w4FX1MF6f12mfjNkXDBScP75/jNyEjNH68bS8";

    # Setup neovim
    programs.neovim = {
        enable = true;
        defaultEditor = true;
    };

    # Enable New CLI and Flakes
    nix.settings.experimental-features = [
        "nix-command"
        "flakes"
    ];

    # Useful packages for installation and recovery
    environment.systemPackages = with pkgs; [
        btrfs-progs
        curl
        git
        parted
        custom.installer
    ];

    # Increase size of tmpfs on /run
    boot.runSize = "50%";

    # Allow easy connection to Wi-Fi (wpa_supplicant sucks)
    networking = {
        networkmanager.enable = true;
        wireless.enable = mkForce false;
    };

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    system.stateVersion = "23.11";
}
