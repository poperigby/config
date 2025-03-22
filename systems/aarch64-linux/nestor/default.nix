{ lib, pkgs, ... }:

let
  inherit (lib) mkForce;
in
{
  time.timeZone = "America/Los_Angeles";

  services = {
    openssh.enable = true;
    octoprint.enable = true;
  };

  networking.networkmanager.enable = true;

  users = {
    users.nixos = {
      hashedPassword = "$y$j9T$t2WW7Q7yFNMpPerSi3FI.0$AALIY.Rd1IcVCS5lcZuZpLWdMCsOw9l7JLgGp4rYFPA";
      isNormalUser = true;
      group = "nixos";
      extraGroups = [ "wheel" ];
    };
    groups.nixos = { };
  };

  boot = {
    kernelPackages = mkForce pkgs.linuxPackages_latest;
    supportedFilesystems = {
      zfs = mkForce false;
    };
    extraModprobeConfig = ''
      # Fix broken WiFi
      options brcmfmac roamoff=1 feature_disable=0x82000
    '';
  };

  # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
