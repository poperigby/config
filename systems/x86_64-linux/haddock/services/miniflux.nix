{ config, lib, ... }:

let
    cfg = config.services.miniflux;
in
{
    services = {
        miniflux = {
            enable = true;
            adminCredentialsFile = config.sops.templates.miniflux-admin-credentials.path;
            # Use my local PostgreSQL database
            createDatabaseLocally = true;
            config = {
                PORT = "8081";
                # OpenID Connect
                OAUTH2_PROVIDER = "oidc";
                OAUTH2_CLIENT_ID_FILE = config.sops.secrets.miniflux-oidc-client-id_miniflux.path;
                OAUTH2_CLIENT_SECRET_FILE = config.sops.secrets.miniflux-oidc-client-secret_miniflux.path;
                OAUTH2_REDIRECT_URL = "https://news.haddock.cc/oauth2/oidc/callback";
                OAUTH2_OIDC_DISCOVERY_ENDPOINT = "https://auth.haddock.cc";
                OAUTH2_USER_CREATION = "1";
            };
        };
        caddy.virtualHosts."news.haddock.cc".extraConfig = ''
            import auth
            reverse_proxy :${cfg.config.PORT}
        '';
    };

    systemd.services.miniflux = {
        unitConfig = {
            After = [
                "authelia-haddock.service"
                "postgresql.service"
            ];
            Requires = [
                "authelia-haddock.service"
                "postgresql.service"
            ];
        };
        # DynamicUser screws up sops-nix ownership
        serviceConfig.DynamicUser = lib.mkForce false;
    };

    # Setup a user and group for Miniflux
    users = {
        users.miniflux = {
            group = "miniflux";
            isSystemUser = true;
        };
        groups.miniflux = {};
    };

    sops = {
        templates.miniflux-admin-credentials = {
            owner = "miniflux";
            content = ''
                ADMIN_USERNAME="admin"
                ADMIN_PASSWORD="${config.sops.placeholder."haddock/miniflux/admin_password"}"
            '';
        };
        secrets = {
            "haddock/miniflux/admin_password" = {};
            # Miniflux
            miniflux-oidc-client-id_miniflux = {
                key = "haddock/miniflux/oidc_client_id";
                owner = "miniflux";
            };
            miniflux-oidc-client-secret_miniflux = {
                key = "haddock/miniflux/oidc_client_secret";
                owner = "miniflux";
            };
            # Authelia (read from authelia/oidc_clients.yaml)
            miniflux-oidc-client-id_authelia = {
                key = "haddock/miniflux/oidc_client_id";
                owner = "authelia-haddock";
            };
            miniflux-oidc-client-secret_authelia = {
                key = "haddock/miniflux/oidc_client_secret";
                owner = "authelia-haddock";
            };
        };
    };
}
