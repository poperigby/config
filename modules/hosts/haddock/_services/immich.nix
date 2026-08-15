{ config, lib, ... }:

let
    inherit (lib.local.caddy) authReverseProxy';

    cfg = config.services.immich;
in
{
    services = {
        immich = {
            enable = true;
            environment = {
                IMMICH_CONFIG_FILE = config.sops.templates.immich-config.path;
            };
        };
        caddy.virtualHosts."photos.haddock.cc".extraConfig = authReverseProxy' cfg.host cfg.port;
        authelia = {
            # https://immich.app/docs/administration/oauth/
            oidcClients.haddock = [
                {
                    client_name = "Immich";
                    client_id = config.sops.placeholder.immich-oidc-client-id_authelia;
                    client_secret = config.sops.placeholder."haddock/immich/oidc_client_secret/authelia";
                    public = false;
                    authorization_policy = "one_factor";
                    redirect_uris = [
                        "app.immich:///oauth-callback"
                        "https://photos.haddock.cc/auth/login"
                        "https://photos.haddock.cc/user-settings"
                    ];
                    scopes = [
                        "openid"
                        "profile"
                        "email"
                    ];
                    token_endpoint_auth_method = "client_secret_post";
                }
            ];
            instances.haddock.settings.access_control.rules = [
                {
                    # Immich handles authorization itself and uses Authelia via OIDC
                    # when authentication is required. Bypass forward auth for the
                    # whole domain so public shares can anonymously load the frontend
                    # assets and API endpoints they need.
                    domain = "photos.haddock.cc";
                    policy = "bypass";
                }
            ];
        };
    };

    sops = {
        templates.immich-config = {
            content = # json
                ''
                    {
                      "backup": {
                        "database": {
                          "enabled": false,
                        }
                      },
                      "newVersionCheck": {
                        "enabled": false
                      },
                      "oauth": {
                        "enabled": true,
                        "clientId": "${config.sops.placeholder.immich-oidc-client-id_immich}",
                        "clientSecret": "${config.sops.placeholder."haddock/immich/oidc_client_secret/immich"}",
                        "issuerUrl": "https://auth.haddock.cc/.well-known/openid-configuration",
                        "scope": "openid profile email",
                        "tokenEndpointAuthMethod": "client_secret_post",
                        "autoLaunch": true,
                        "autoRegister": true,
                        "defaultStorageQuota": 0,
                        "mobileOverrideEnabled": false,
                        "mobileRedirectUri": "",
                        "profileSigningAlgorithm": "none",
                        "signingAlgorithm": "RS256",
                        "storageLabelClaim": "preferred_username",
                        "storageQuotaClaim": "immich_quota",
                        "timeout": 30000,
                        "buttonText": "Login with Authelia"
                      },
                      "passwordLogin": {
                        "enabled": false
                      },
                    }
                '';
            owner = "immich";
        };
        secrets = {
            immich-oidc-client-id_immich = {
                key = "haddock/immich/oidc_client_id";
                owner = cfg.user;
            };
            immich-oidc-client-id_authelia = {
                key = "haddock/immich/oidc_client_id";
                owner = "authelia-haddock";
            };
            "haddock/immich/oidc_client_secret/immich".owner = cfg.user;
            "haddock/immich/oidc_client_secret/authelia".owner = "authelia-haddock";
        };
    };
}
