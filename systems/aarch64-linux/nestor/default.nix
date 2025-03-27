{ lib, modulesPath, ... }:

{
  imports = [
    ./octoprint.nix
    (lib.mkAliasOptionModuleMD [ "environment" "checkConfigurationOptions" ] [ "_module" "check" ])
  ];

  disabledModules = [
    (modulesPath + "/rename.nix")
  ];

  time.timeZone = "America/Los_Angeles";

  services = {
    openssh.enable = true;
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

  # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
