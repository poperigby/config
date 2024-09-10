{ config, ... }:

let
    cfg = config.services.gatus;
in
{
    services = {
        gatus = {
            enable = true;
            settings = {
                endpoints = [
                    {
                        name = "Authelia";
                        url = "http://localhost:9091";
                        interval = "5m";
                        conditions = [
                            "[STATUS] == 200"
                        ];
                    }
                    {
                        name = "Jellyfin";
                        url = "http://localhost:8096";
                        interval = "5m";
                        conditions = [
                            "[STATUS] == 200"
                        ];
                    }
                    {
                        name = "LLDAP";
                        url = "https://users.haddock.cc";
                        interval = "5m";
                        conditions = [
                            "[STATUS] == 200"
                        ];
                    }
                    {
                        name = "Mealie";
                        url = "http://localhost:${builtins.toString config.services.mealie.port}";
                        interval = "5m";
                        conditions = [
                            "[STATUS] == 200"
                        ];
                    }
                    {
                        name = "Miniflux";
                        url = "http://localhost:${config.services.miniflux.config.PORT}";
                        interval = "5m";
                        conditions = [
                            "[STATUS] == 200"
                        ];
                    }
                    {
                        name = "Prowlarr";
                        url = "http://localhost:9696";
                        interval = "5m";
                        conditions = [
                            "[STATUS] == 200"
                        ];
                    }
                    {
                        name = "Radarr";
                        url = "http://localhost:7878";
                        interval = "5m";
                        conditions = [
                            "[STATUS] == 200"
                        ];
                    }
                    {
                        name = "Sonarr";
                        url = "http://localhost:8989";
                        interval = "5m";
                        conditions = [
                            "[STATUS] == 200"
                        ];
                    }
                ];
            };
        };
        caddy.virtualHosts."status.haddock.cc".extraConfig = ''
            import auth
            reverse_proxy :${builtins.toString cfg.settings.web.port}
        '';
    };
}
