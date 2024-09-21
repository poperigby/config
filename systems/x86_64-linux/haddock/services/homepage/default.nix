{ config, ... }:

let
    cfg = config.services.homepage-dashboard;
in
{
    services = {
        homepage-dashboard = {
            enable = true;
            listenPort = 8084;
            settings = {
                title = "Haddock";
                background.image = ./oregon.jpg;
                quicklaunch.showSearchSuggestions = true;
            };
        };
        caddy.virtualHosts."haddock.cc".extraConfig = ''
            import auth
            reverse_proxy :${toString cfg.listenPort}
        '';
    };
}
