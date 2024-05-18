{ config, lib, ... }:

let
    cfg = config.poperigby.programs.wezterm;
in
{
    options.poperigby.programs.wezterm.enable = lib.mkEnableOption "Enable WezTerm";

    config = lib.mkIf cfg.enable {
        programs.wezterm = {
            enable = true;
            extraConfig = builtins.readFile ./wezterm.lua;
        };
    };
}
