{ modulesPath, ... }:

{
  disabledModules = [
    (modulesPath + "/rename.nix")
  ];

  time.timeZone = "America/Los_Angeles";

  services = {
    openssh.enable = true;
    octoprint = {
      enable = true;
      plugins =
        plugins: with plugins; [
          # Show IP address on Prusa screen
          IpOnConnect
        ];
      extraConfig = {
        # Allow communicating with printer over serial connection
        # https://help.prusa3d.com/article/octoprint-configuration-and-install_2182#configure-rpi-zero-w-gpio
        serial = {
          additionalPorts = [ "/dev/ttyAMA0" ];
          autoconnect = true;
          baudrate = 115200;
          port = "/dev/ttyAMA0";
        };
      };
    };
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
