{ lib, pkgs, ... }:

let
  inherit (lib) getExe;
in
{
  custom = {
    suites = {
      common.enable = true;
      gaming = {
        enable = true;
        bethesda = true;
      };
      gui = {
        enable = true;
        resolution = "2560x1440";
        refreshRate = 165;
        vrr = true;
        wallpaper = ./wallpaper.jpg;
      };
    };
    services.ludusavi.settings = {
      manifest.url = "https://raw.githubusercontent.com/mtkennerly/ludusavi-manifest/master/data/manifest.yaml";
      # Game library roots from which saves will be backed up
      roots = [
        {
          path = "~/.local/share/Steam";
          store = "steam";
        }
        {
          path = "~/.config/heroic";
          store = "heroic";
        }
        {
          path = "/mnt/ssd0/SteamLibrary";
          store = "steam";
        }
        {
          path = "/mnt/hdd0/SteamLibrary";
          store = "steam";
        }
      ];
      customGames = [
        {
          name = "OpenMW";
          files = [ "~/.local/share/openmw/saves" ];
        }
        {
          name = "GZDoom";
          files = [ "~/.config/gzdoom/savegames" ];
        }
      ];
      backup.path = "~/.local/state/backups/ludusavi";
      restore.path = "~/.local/state/backups/ludusavi";
    };
  };

  # Controls Corsair hardware
  wayland.windowManager.sway.config.startup = [
    {
      command = "${getExe pkgs.ckb-next} --background";
    }
  ];

  # home.packages = with pkgs; [
  #     blender-hip
  # ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
