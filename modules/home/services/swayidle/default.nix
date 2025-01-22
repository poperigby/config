{ config, lib, ... }:

let
  inherit (lib)
    getExe
    mkEnableOption
    mkIf
    mkOption
    ;

  inherit (lib.types)
    submodule
    int
    ;

  cfg = config.custom.services.swayidle;
  swaylock = getExe config.programs.swaylock.package;
in
{
  options.custom.services.swayidle = {
    enable = mkEnableOption "idle daemon";
    timeouts = mkOption {
      type = submodule {
        options = {
          lock = mkOption {
            type = int;
            description = "Idle time (in seconds) until the screen will lock";
          };
          sleep = mkOption {
            type = int;
            description = "Idle time (in seconds) until the system will go to sleep";
          };
        };
      };
      default = {
        lock = 1800; # 30 minutes
        sleep = 3600; # 1 hour
      };
    };
  };

  config = mkIf cfg.enable {
    services.swayidle = {
      enable = true;
      events = [
        {
          event = "before-sleep";
          command = "${swaylock} -fF";
        }
        {
          event = "lock";
          command = "lock";
        }
      ];
      timeouts = [
        {
          timeout = cfg.timeouts.lock;
          command = "${swaylock} -fF";
        }
        {
          timeout = cfg.timeouts.sleep;
          command = "systemctl suspend";
        }
      ];
    };
  };
}
