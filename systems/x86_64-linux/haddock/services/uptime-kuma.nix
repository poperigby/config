{ config, ... }:

let
    cfg = config.services.uptime-kuma;
in
{
    services = {
        uptime-kuma = {
            enable = true;
        };
        caddy.virtualHosts."status.haddock.cc".extraConfig = ''
            import auth
            reverse_proxy localhost:${cfg.settings.PORT}
        '';
    };
}
