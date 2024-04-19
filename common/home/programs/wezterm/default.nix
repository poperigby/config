{ config, lib, ... }:

let
    cfg = config.modules.home.wezterm;
in
{
    options.modules.home.wezterm.enable = lib.mkEnableOption "Enable WezTerm";

    config = lib.mkIf cfg.enable {
        programs.wezterm = {
            enable = true;
            extraConfig = builtins.readFile ./wezterm.lua;
        };
    };
}
