{ config, lib, pkgs, ... }:

let
    inherit (lib)
        mkEnableOption
        mkIf
    ;

    inherit (lib.strings) toJSON;

    cfg = config.poperigby.programs.element-desktop;
in
{
    options.poperigby.programs.element-desktop.enable = mkEnableOption "Element Desktop";

    config = mkIf cfg.enable {
        home.packages = [ pkgs.element-desktop ];

        xdg.configFile."Element/config.json".text = toJSON {
            show_labs_settings = true;
        };
    };
}
