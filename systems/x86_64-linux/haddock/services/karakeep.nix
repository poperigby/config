{ config, pkgs, ... }:

let
    port = "3001";
in
{
    services = {
        karakeep = {
            enable = true;
            extraEnvironment = {
                # https://docs.karakeep.app/configuration
                DISABLE_NEW_RELEASE_CHECK = "true";
                NEXTAUTH_URL = "https://keep.haddock.cc";
                PORT = port;
                # Authentication
                DISABLE_PASSWORD_AUTH = "true";
                NEXTAUTH_URL_INTERNAL = "http://localhost:${port}";
                # OpenID
                OAUTH_WELLKNOWN_URL = "https://auth.haddock.cc/.well-known/openid-configuration";
                OAUTH_PROVIDER_NAME = "Authelia";
            };
            environmentFile = config.sops.templates.karakeep-secrets.path;
        };
        caddy.virtualHosts."keep.haddock.cc".extraConfig = ''
            import auth
            reverse_proxy :${port}
        '';
        authelia.instances.haddock.settings.access_control.rules = [
            {
                # Required to use the Karakeep mobile app and browser extension
                domain = "keep.haddock.cc";
                policy = "bypass";
                resources = [ "/api.*" ];
            }
        ];
        meilisearch = {
            package = pkgs.meilisearch;
            settings.experimental_dumpless_upgrade = true;
        };
    };

    sops = {
        templates.karakeep-secrets.content = # bash
            ''
                OAUTH_CLIENT_ID=${config.sops.placeholder.karakeep-oidc-client-id_karakeep}
                OAUTH_CLIENT_SECRET=${config.sops.placeholder."haddock/karakeep/oidc_client_secret/karakeep"}
            '';
        secrets = {
            karakeep-oidc-client-id_karakeep = {
                key = "haddock/karakeep/oidc_client_id";
                owner = "karakeep";
            };
            karakeep-oidc-client-id_authelia = {
                key = "haddock/karakeep/oidc_client_id";
                owner = "authelia-haddock";
            };
            "haddock/karakeep/oidc_client_secret/karakeep".owner = "karakeep";
            "haddock/karakeep/oidc_client_secret/authelia".owner = "authelia-haddock";
        };
    };
}
