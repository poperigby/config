{ ... }:

{
  imports = [
    ./drives.nix
    ./hardware.nix
  ];

  custom = {
    hardware = {
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
            # Skyrim load order, custom LOOT rules, etc.
            "${cassidy}/.local/share/Steam/steamapps/compatdata/489830/pfx/drive_c/users/steamuser/AppData/Local/Skyrim Special Edition"
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

  programs.adb.enable = true;

  time.timeZone = "America/Los_Angeles";

  networking.networkmanager.enable = true;

  services.lact.enable = true;

  # TODO: Allow key-only auth
  # Having SSHD enabled is pretty handy sometimes
  #services.openssh.enable = true;

  # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
