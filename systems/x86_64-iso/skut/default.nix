{ lib, pkgs, ... }:

{
  users.users.nixos.password = "nixos";

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

  # Allows easy connection to Wi-Fi (wpa_supplicant sucks)
  networking = {
    networkmanager.enable = true;
    wireless.enable = lib.mkForce false;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
