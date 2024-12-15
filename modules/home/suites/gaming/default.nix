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
    ;

  cfg = config.poperigby.suites.gaming;
in
{
  options.poperigby.suites.gaming.enable = mkEnableOption "various programs/tweaks for gaming";

  config = mkIf cfg.enable {
    poperigby = {
      programs = {
        # MangoHUD, for monitoring hardware and software during gameplay
        mangohud.enable = true;
        morrowind.enable = true;
      };
      services = {
        # For backing up games
        ludusavi.enable = true;
      };
    };

    # Packages
    home.packages = with pkgs; [
      # For GOG and Epic Games 🤢
      heroic
      # For managing compatibility tools
      protonup-qt
      # For limiting FPS
      libstrangle
      # Doom
      doomrunner
      gzdoom
      # Build Engine
      raze
      # Quake
      vkquake
      # Minecraft
      prismlauncher
      # Bethesda
      jpexs
      limo
      nifskope
      poperigby.libwinpath
      poperigby.loot
      poperigby.synthesis
      protontricks
    ];

    home.sessionVariables = {
      # Let GZDoom know where IWADs are
      DOOMWADDIR = "${config.home.homeDirectory}/Games/Doom/IWADs";
    };

    xdg.mimeApps.defaultApplications."application/vnd.adobe.flash.movie" = "ffdec.desktop";
  };
}
