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
                clock = true;
                effect-compose = "${gui.wallpaper}";
            };
        };
    };
}
