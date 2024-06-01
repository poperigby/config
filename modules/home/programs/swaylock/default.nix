{ config, lib, pkgs, ... }:

let
    cfg = config.poperigby.programs.swaylock;
    gui = config.poperigby.suites.gui;
in
{
    options.poperigby.programs.swaylock.enable = lib.mkEnableOption "Enable swaylock";

    config = lib.mkIf cfg.enable {
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
