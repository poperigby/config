{ config, lib, pkgs, ... }:

let
    inherit (lib)
        mkEnableOption
        mkIf
    ;

    cfg = config.poperigby.hardware.scanning;
    gui = config.poperigby.suites.gui;
in
{
    options.poperigby.hardware.scanning.enable = mkEnableOption "scanning";

    config = mkIf cfg.enable {
        hardware.sane = {
            enable = true;
            # To make my Epson v600 Photo work
            extraBackends = [ pkgs.epkowa ];
        };

        environment.systemPackages = mkIf gui.enable [
            pkgs.kdePackages.skanpage
        ];
    };
}
