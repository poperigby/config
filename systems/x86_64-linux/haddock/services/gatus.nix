{ config, inputs, lib, ... }:

let
    cfg = config.services.gatus;
in
{
    imports = [ "${inputs.gatus}/nixos/modules/services/monitoring/gatus.nix" ];

    services = {
        gatus = {
            enable = true;
            settings = {
                debug = true;
                endpoints = [
                    {
                        name = "Nextcloud";
                        url = "https://cloud.haddock.cc";
                        interval = "5m";
                        conditions = [
                            "[STATUS] == 200"
                        ];
                    }
                    {
                        name = "Authelia";
                        url = "https://auth.haddock.cc";
                        interval = "5m";
                        conditions = [
                            "[STATUS] == 200"
                        ];
                    }
                    {
                        name = "Mealie";
                        url = "https://food.haddock.cc";
                        interval = "5m";
                        conditions = [
                            "[STATUS] == 200"
                        ];
                    }
                    {
                        name = "Miniflux";
                        url = "https://news.haddock.cc";
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
                        name = "Sonarr";
                        url = "https://tv.haddock.cc";
                        interval = "5m";
                        conditions = [
                            "[STATUS] == 200"
                        ];
                    }
                    {
                        name = "Radarr";
                        url = "https://movies.haddock.cc";
                        interval = "5m";
                        conditions = [
                            "[STATUS] == 200"
                        ];
                    }
                    {
                        name = "Prowlarr";
                        url = "https://indexers.haddock.cc";
                        interval = "5m";
                        conditions = [
                            "[STATUS] == 200"
                        ];
                    }
                    {
                        name = "PrusaLink";
                        url = "https://print.haddock.cc";
                        interval = "5m";
                        conditions = [
                            "[STATUS] == 200"
                        ];
                    }
                    {
                        name = "Jellyfin";
                        url = "https://media.haddock.cc";
                        interval = "5m";
                        conditions = [
                            "[STATUS] == 200"
                        ];
                    }
                ];
                security.oidc = {
                    issuer-url = "https://auth.haddock.cc";
                    redirect-url = "https://status.haddock.cc/authorization-code/callback";
                    client-id = "$OIDC_CLIENT_ID";
                    client-secret = "$OIDC_CLIENT_SECRET";
                    scopes = [ "openid" ];
                };
            };
            environmentFile = config.sops.templates.gatus-secrets.path;
        };
        caddy.virtualHosts."status.haddock.cc".extraConfig = ''
            import auth
            reverse_proxy :${builtins.toString cfg.settings.web.port}
        '';
    };

    # Setup a user and group for Gatus
    users = {
        users.gatus = {
            group = "gatus";
            isSystemUser = true;
        };
        groups.gatus = {};
    };

    # DynamicUser screws up sops-nix ownership
    systemd.services.gatus.serviceConfig.DynamicUser = lib.mkForce false;

    sops = {
        templates.gatus-secrets = {
            content = ''
                OIDC_CLIENT_ID=${config.sops.placeholder.gatus-oidc-client-id_gatus} 
                OIDC_CLIENT_SECRET=${config.sops.placeholder.gatus-oidc-client-secret_gatus} 
            '';
            owner = "gatus";
        };
        secrets = {
            # Gatus
            gatus-oidc-client-id_gatus = {
                key = "haddock/gatus/oidc_client_id";
                owner = "gatus";
            };
            gatus-oidc-client-secret_gatus = {
                key = "haddock/gatus/oidc_client_secret";
                owner = "gatus";
            };
            # Authelia
            gatus-oidc-client-id_authelia = {
                key = "haddock/gatus/oidc_client_id";
                owner = "authelia-haddock";
            };
            gatus-oidc-client-secret_authelia = {
                key = "haddock/gatus/oidc_client_secret";
                owner = "authelia-haddock";
            };
        };
    };
}
