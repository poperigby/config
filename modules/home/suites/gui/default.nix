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
    mkOption
    ;

  inherit (lib.types)
    float
    int
    nullOr
    path
    str
    ;

  cfg = config.custom.suites.gui;
in
{
  options.custom.suites.gui = {
    enable = mkEnableOption "GUI";
    resolution = mkOption {
      type = str;
      default = "";
      description = "The resolution you want to use, in the form of <width>x<height>";
    };
    scale = mkOption {
      type = float;
      default = 1.0;
      description = "Scale factor";
    };
    refreshRate = mkOption {
      type = int;
      default = 60;
      description = "The refresh rate you want to use";
    };
    vrr = mkEnableOption "Variable refresh rate (adaptive sync)";
    wallpaper = mkOption {
      type = nullOr path;
      default = null;
      description = "The path to a wallpaper you want to use.";
    };
  };

  config = mkIf cfg.enable {
    custom = {
      programs = {
        discord.enable = true;
        firefox.enable = true;
        mpv.enable = true;
        thunderbird.enable = true;
        wezterm.enable = true;
      };
    };

    # Packages that don't need any configuration
    home.packages = with pkgs; [
      bottles
      cinny-desktop
      gimp
      inkscape
      onlyoffice-bin
      signal-desktop
      tenacity
      tor-browser
    ];

    # Generate $XDG_CONFIG_HOME/mimeapps.list for setting default applications
    xdg.mimeApps.enable = true;

    # Enable Wayland for Chromium and Electron based apps
    home.sessionVariables.NIXOS_OZONE_WL = 1;
  };
}
