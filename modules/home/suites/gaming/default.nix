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

  cfg = config.custom.suites.gaming;
in
{
  options.custom.suites.gaming.enable = mkEnableOption "various programs/tweaks for gaming";

  config = mkIf cfg.enable {
    custom = {
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
      custom.dar2oar
      custom.hkxc
      custom.libwinpath
      custom.loot
      custom.synthesis
      protontricks
    ];

    home.sessionVariables = {
      # Let GZDoom know where IWADs are
      DOOMWADDIR = "${config.home.homeDirectory}/Games/Doom/IWADs";
    };

    xdg.mimeApps.defaultApplications."application/vnd.adobe.flash.movie" = "ffdec.desktop";
  };
}
