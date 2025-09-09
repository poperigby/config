{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    getExe
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.services.joystickwake;
in
{
  options.custom.services.joystickwake.enable = mkEnableOption "joystickwake daemon";

  config = mkIf cfg.enable {
    systemd.user.services.joystickwake = {
      Unit = {
        Description = "Wake screensaver/DPMS when using joystick";
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = getExe pkgs.joystickwake;
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
