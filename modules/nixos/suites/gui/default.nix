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

  cfg = config.custom.suites.gui;
in
{
  options.custom.suites.gui = {
    enable = mkEnableOption "GUI";
  };

  config = mkIf cfg.enable {
    custom = {
      services = {
        udisks2.enable = true;
      };
    };

    programs.wireshark.enable = true;
    environment.systemPackages = with pkgs; [ wireshark-qt ];

    # Show desktop notifications for system bus
    services.systembus-notify.enable = true;
  };
}
