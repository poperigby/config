{ config, lib, ... }:

let
    inherit (lib)
        getExe
        mkEnableOption
        mkIf
    ;

    cfg = config.poperigby.services.swayidle;
    swaylock = getExe config.programs.swaylock.package;
in
{
    options.poperigby.services.swayidle.enable = mkEnableOption "idle daemon";

    config = mkIf cfg.enable {
        services.swayidle = {
            enable = true;
            events = [
                { event = "before-sleep"; command = "${swaylock} -fF"; }
                { event = "lock"; command = "lock"; }
            ];
            timeouts = [
                {
                    # After 5 minutes, lock screen
                    timeout = 300;
                    command = "${swaylock} -fF";
                }
                {
                    # After 10 minutes, go to sleep
                    timeout = 600;
                    command = "systemctl suspend";
                }
            ];
        };
    };
}
