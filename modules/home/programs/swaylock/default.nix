{ config, lib, pkgs, ... }:

let
    cfg = config.poperigby.programs.swaylock;
in
{
    options.poperigby.programs.swaylock.enable = lib.mkEnableOption "Enable swaylock";

    config = lib.mkIf cfg.enable {
        programs.swaylock = {
            enable = true;
            package = pkgs.swaylock-effects;
        };
    };
}
