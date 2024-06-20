{ config, ... }:

let
    cfg = config.services.scrutiny;
in
{
    services = {
        scrutiny = {
            enable = true;
            settings = {
                web.listen.port = 8082;
            };
            collector = {
                # Why is this disabled by default?
                enable = true;
            };
        };
        caddy.virtualHosts."drives.haddock.cc".extraConfig = ''
            import auth
            reverse_proxy :${builtins.toString cfg.settings.web.listen.port}
        '';
    };
}
