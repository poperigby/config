{ config, ... }:

let
  cfg = config.services.silverbullet;
in
{
  services = {
    silverbullet = {
      enable = true;
    };
    caddy.virtualHosts."notes.haddock.cc".extraConfig = ''
      import auth
      reverse_proxy :${toString cfg.listenPort}
    '';
  };
}
