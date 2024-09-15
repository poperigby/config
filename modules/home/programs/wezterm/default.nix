{ config, lib, ... }:

let
    inherit (lib)
        mkEnableOption
        mkIf
        readFile
    ;

    cfg = config.poperigby.programs.wezterm;
in
{
    options.poperigby.programs.wezterm.enable = mkEnableOption "WezTerm";

    config = mkIf cfg.enable {
        programs.wezterm = {
            enable = true;
            extraConfig = readFile ./wezterm.lua;
        };
    };
}
