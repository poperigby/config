{ config, lib, ... }:

let
    cfg = config.services.mealie;
in
{
    services = {
        mealie = {
            enable = true;
            credentialsFile = config.sops.templates.mealie-secrets.path;
            settings = {
                ALLOW_SIGNUP = "false";
                MAX_WORKERS = 1;
                WEB_CONCURRENCY = 1;
                BASE_URL = "https://food.haddock.cc";
                # Time until session expires
                TOKEN_TIME = 2200;
                # Database
                DB_ENGINE = "postgres";
                # https://github.com/mealie-recipes/mealie/issues/3573
                POSTGRES_URL_OVERRIDE = "postgresql://mealie:@localhost/mealie?host=/run/postgresql";
                # OpenID Connect
                OIDC_AUTH_ENABLED = "true";
                OIDC_SIGNUP_ENABLED = "true";
                OIDC_CONFIGURATION_URL = "https://auth.haddock.cc/.well-known/openid-configuration";
                OIDC_AUTO_REDIRECT = "true";
                OIDC_ADMIN_GROUP = "lldap_admin";
            };
        };
        caddy.virtualHosts."food.haddock.cc".extraConfig = ''
            import auth
            reverse_proxy :${builtins.toString cfg.port}
        '';
    };

    systemd.services.mealie = let
        dependencies = [
            "postgresql.service"
        ];
    in {
        after = dependencies;
        requires = dependencies;
        # DynamicUser messes with sops-nix
        serviceConfig.DynamicUser = lib.mkForce false;
    };

    # Setup a user and group for Mealie
    users = {
        users.mealie = {
            group = "mealie";
            isSystemUser = true;
        };
        groups.mealie = {};
    };

    sops = {
        templates.mealie-secrets = {
            content = ''
                OIDC_CLIENT_ID=${config.sops.placeholder.mealie-oidc-client-id_mealie}
            '';
            owner = "mealie";
        };
        secrets = {
            mealie-oidc-client-id_mealie = {
                key = "haddock/mealie/oidc_client_id";
                owner = "mealie";
            };
            mealie-oidc-client-id_authelia = {
                key = "haddock/mealie/oidc_client_id";
                owner = "authelia-haddock";
            };
        };
    };
}
