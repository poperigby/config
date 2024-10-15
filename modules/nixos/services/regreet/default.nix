{ config, lib, ... }:

let
    inherit (lib)
        mkEnableOption
        mkIf
    ;

    cfg = config.poperigby.services.regreet;
in
{
    options.poperigby.services.regreet.enable = mkEnableOption "Enable Regreet login manager";

    config = mkIf cfg.enable {
        programs.regreet = {
            enable = true;
            settings = {
                GTK = {
                    application_prefer_dark_theme = true;
                };
            };
        };
    };
}
