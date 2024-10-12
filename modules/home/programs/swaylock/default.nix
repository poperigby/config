{ config, lib, pkgs, ... }:

let
    inherit (lib)
        mkEnableOption
        mkIf
    ;

    cfg = config.poperigby.programs.swaylock;
    gui = config.poperigby.suites.gui;
in
{
    options.poperigby.programs.swaylock.enable = mkEnableOption "Swaylock";

    config = mkIf cfg.enable {
        programs.swaylock = {
            enable = true;
            package = pkgs.swaylock-effects;
            settings = {
                # Clock
                clock = true;
                timestr = "%H:%M";
                # Indicator
                indicator-idle-visible = true;
                indicator-radius = 100;
                # Background
                image = toString gui.wallpaper;
                effect-blur = "7x5";
            };
        };
    };
}
