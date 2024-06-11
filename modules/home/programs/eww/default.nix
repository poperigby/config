{ config, lib, ... }:

let
    cfg = config.poperigby.programs.eww;
in
{
    options.poperigby.programs.eww.enable = lib.mkEnableOption "Enable eww";

    config = lib.mkIf cfg.enable {
        programs.eww = {
            enable = true;
            configDir = ./config;
        };
    };
}
