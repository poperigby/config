{ config, ... }:

{
    services = {
        atticd = {
            enable = true;
            environmentFile = config.sops.templates."atticd-environment".path;
            settings = {
                listen = "[::1]:8080";
                allowed-hosts = [ "cache.haddock.cc" ];
                api-endpoint = "https://cache.haddock.cc/";
                database.url = "postgresql://atticd@localhost/atticd?host=%2Frun%2Fpostgresql";
                garbage-collection = {
                    interval = "12 hours";
                    default-retention-period = "6 months";
                };
            };
        };

        caddy.virtualHosts."cache.haddock.cc".extraConfig = ''
            reverse_proxy [::1]:8080
        '';

        postgresql = {
            ensureDatabases = [ "atticd" ];
            ensureUsers = [
                {
                    name = "atticd";
                    ensureDBOwnership = true;
                }
            ];
        };
    };

    systemd.services.atticd = {
        after = [ "postgresql.target" ];
        requires = [ "postgresql.target" ];
    };

    sops = {
        secrets."haddock/attic/jwt_secret" = { };
        templates."atticd-environment" = {
            content = ''
                ATTIC_SERVER_TOKEN_HS256_SECRET_BASE64=${config.sops.placeholder."haddock/attic/jwt_secret"}
            '';
            restartUnits = [ "atticd.service" ];
        };
    };
}
