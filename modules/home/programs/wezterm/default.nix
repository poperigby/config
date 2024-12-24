{ config, lib, ... }:

let
    inherit (lib)
        mkEnableOption
        mkIf
        readFile
    ;

    cfg = config.custom.programs.wezterm;
in
{
    options.custom.programs.wezterm.enable = mkEnableOption "WezTerm";

    config = mkIf cfg.enable {
        programs.wezterm = {
            enable = true;
            extraConfig = readFile ./wezterm.lua;
        };
    };
}
