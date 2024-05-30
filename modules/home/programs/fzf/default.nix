{ config, lib, ... }:

let
    cfg = config.poperigby.programs.fzf;
in
{
    options.poperigby.programs.fzf.enable = lib.mkEnableOption "Enable fzf";

    config = lib.mkIf cfg.enable {
        programs.fzf = {
            enable = true;
            colors = {
                "fg" = "#ebdbb2";
                "fg+" = "#ebdbb2";
                "header" = "#665c54";
                "hl" = "#fabd2f";
                "hl+" = "#fabd2f";
                "info" = "#83a598";
                "marker" = "#fe8019";
                "pointer" = "#83a598";
                "prompt" = "#bdae93";
                "spinner" = "#fabd2f";
            };
        };
    };
}
