{ config, ... }:

let
  cfg = config.custom.services.findMyDeviceServer;
in
{
  custom.services.findMyDeviceServer = {
    enable = true;
    port = 8081;
  };

  services.caddy.virtualHosts."devices.haddock.cc".extraConfig = ''
    reverse_proxy :${toString cfg.port}
  '';
}
