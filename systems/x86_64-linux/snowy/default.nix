{ ... }:

{
  imports = [
    ./drives.nix
    ./hardware.nix
  ];

  custom = {
    hardware = {
      android.enable = true;
      audio.enable = true;
      bluetooth.enable = true;
      corsair.enable = true;
      printing.enable = true;
      scanning.enable = true;
    };
    services = {
      backups =
        let
          cassidy = "/home/cassidy";
        in
        {
          enable = true;
          paths = [
            "/home/*/.local/state/backups"
            # Modding setups
            "${cassidy}/Games/Modding"
          ];
          exclude = [
            "${cassidy}/Games/Modding/Games/*/_download/"
          ];
        };
      earlyoom.enable = true;
      geolocation.enable = true;
      virtualization.enable = true;
    };
    suites = {
      common.enable = true;
      gaming.enable = true;
      gui.enable = true;
    };
    desktops.sway.enable = true;
    users.cassidy.enable = true;
  };

  time.timeZone = "America/Los_Angeles";

  networking.networkmanager.enable = true;

  services.lact.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      # https://www.digitalocean.com/community/tutorials/how-to-harden-openssh-on-ubuntu-20-04
      PermitRootLogin = "no";
      MaxAuthTries = 3;
      PasswordAuthentication = false;
      PermitEmptyPasswords = false;
      ChallengeResponseAuthentication = false;
      PermitUserEnvironment = false;
      AllowAgentForwarding = false;
      AllowTcpForwarding = false;
      PermitTunnel = false;
    };
  };

  # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
