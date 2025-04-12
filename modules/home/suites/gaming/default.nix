{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    optionals
    ;

  cfg = config.custom.suites.gaming;
  bethesda = config.custom.suites.gaming.bethesda;
in
{
  options.custom.suites.gaming = {
    enable = mkEnableOption "various programs/tweaks for gaming";
    bethesda = mkEnableOption "various programs for Bethesda games";
  };

  config = mkIf cfg.enable {
    custom = {
      programs = {
        # MangoHUD, for monitoring hardware and software during gameplay
        mangohud.enable = true;
        morrowind.enable = bethesda;
      };
      services = {
        # For backing up games
        ludusavi.enable = true;
      };
    };

    # Packages
    home.packages =
      with pkgs;
      [
        protontricks
        # For GOG and Epic Games 🤢
        heroic
        # For managing compatibility tools
        protonup-qt
        # For limiting FPS
        libstrangle
        # Doom
        doomrunner
        gzdoom
        # Quake
        vkquake
        # Minecraft
        prismlauncher
        gpu-screen-recorder-gtk
      ]
      ++ optionals bethesda [
        limo
        custom.loot
      ];

    home.sessionVariables = {
      # Let GZDoom know where IWADs are
      DOOMWADDIR = "${config.home.homeDirectory}/Games/Doom/IWADs";
    };

    xdg.mimeApps.defaultApplications."application/vnd.adobe.flash.movie" = "ffdec.desktop";
  };
}
