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
      lact = {
        enable = true;
        gpuOverclock.enable = true;
        settings = {
          daemon = {
            log_level = "info";
            admin_groups = [
              "wheel"
              "sudo"
            ];
            disable_clocks_cleanup = false;
          };
          apply_settings_timer = 5;
          gpus = {
            "1002:73DF-148C:2310-0000:03:00.0" = {
              fan_control_enabled = false;
              performance_level = "manual";
              power_profile_mode_index = 1;
              power_states = {
                core_clock = [
                  0
                  1
                ];
                memory_clock = [
                  0
                  1
                  2
                  3
                ];
              };
            };
          };
        };

      };
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

  # TODO: Allow key-only auth
  # Having SSHD enabled is pretty handy sometimes
  #services.openssh.enable = true;

  # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
