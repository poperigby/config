{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.hardware.scanning;
  gui = config.custom.suites.gui;
in
{
  options.custom.hardware.scanning.enable = mkEnableOption "scanning";

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
