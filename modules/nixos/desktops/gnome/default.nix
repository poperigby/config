{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.custom.desktops.gnome;
in
{
  options.custom.desktops.gnome = {
    enable = mkEnableOption "GNOME Desktop";
  };

  config = mkIf cfg.enable {
    services = {
      xserver = {
        displayManager.gdm.enable = true;
        desktopManager.gnome.enable = true;
      };
      # For system tray icons
      udev.packages = [ pkgs.gnome-settings-daemon ];
    };

    # Extensions
    environment.systemPackages = with pkgs.gnomeExtensions; [
      # For system tray icons
      appindicator
    ];
  };
}
