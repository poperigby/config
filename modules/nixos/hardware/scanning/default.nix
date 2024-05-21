{ config, lib, pkgs, ... }:

let
  cfg = config.poperigby.hardware.scanning;
in
{
    options.poperigby.hardware.scanning.enable = lib.mkEnableOption "Enable scanning";

    config = lib.mkIf cfg.enable {
        hardware.sane = {
            enable = true;
            # To make my Epson v600 Photo work
            extraBackends = [ pkgs.epkowa ];
        };
    };
}
