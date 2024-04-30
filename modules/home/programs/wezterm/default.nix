{ config, lib, ... }:

let
    cfg = config.common.home.wezterm;
in
{
    options.common.home.wezterm.enable = lib.mkEnableOption "Enable WezTerm";

    config = lib.mkIf cfg.enable {
        programs.wezterm = {
            enable = true;
            extraConfig = builtins.readFile ./wezterm.lua;
        };
    };
}
