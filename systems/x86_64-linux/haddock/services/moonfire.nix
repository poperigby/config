{ config, ... }:

let
    cfg = config.custom.services.moonfire-nvr;
in
{
    custom.services.moonfire-nvr = {
        enable = true;
        port = 1024;
    };

    services.caddy.virtualHosts."cctv.haddock.cc".extraConfig = ''
        import auth
        reverse_proxy :${toString cfg.port}
    '';
}
