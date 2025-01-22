{ config, lib, ... }:

let
  cfg = config.custom.services.earlyoom;
  gui = config.custom.suites.gui.enable;
in
{
  options.custom.services.earlyoom.enable = lib.mkEnableOption "Early OOM";

  config = lib.mkIf cfg.enable {
    services.earlyoom = {
      enable = true;
      # <%5 free
      freeMemThreshold = 5;
      # Enable desktop notifications if GUI suite is enabled
      enableNotifications = gui;
    };
  };
}
