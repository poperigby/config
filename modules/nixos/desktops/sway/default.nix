{
  config,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.custom.desktops.sway;
in
{
  options.custom.desktops.sway = {
    enable = mkEnableOption "Sway WM";
  };

  config = mkIf cfg.enable {
    security = {
      # Required for Sway to launch
      polkit.enable = true;
      # Required for Swaylock to work
      pam.services.swaylock = { };
    };

    # Required for tweaking GTK settings
    programs.dconf.enable = true;

    # Required for Sway to run
    hardware.graphics.enable = true;
  };
}
