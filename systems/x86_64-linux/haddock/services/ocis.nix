{ config, inputs, system, ... }:

let
    cfg = config.services.ocis;
in
{
    services = {
        ocis = {
            enable = true;
            package = inputs.ocis.legacyPackages.${system}.ocis;
            environment = {
                # OIDC
                OCIS_OIDC_ISSUER = "https://auth.haddock.cc";
                PROXY_OIDC_REWRITE_WELLKNOWN = "true";
                PROXY_AUTOPROVISION_ACCOUNTS = "true";
            };
            environmentFile = config.sops.templates.ocis-secrets.path;
        };
        caddy.virtualHosts."files.haddock.cc".extraConfig = ''
            import auth
            reverse_proxy :${toString cfg.port}
        '';
    };

    sops = {
        templates.ocis-secrets = {
            content = # bash
            ''
                # General
                GATEWAY_STORAGE_USERS_MOUNT_ID=${config.sops.placeholder."haddock/ocis/gateway_storage_users_mount_id"}
                OCIS_JWT_SECRET=${config.sops.placeholder."haddock/ocis/jwt_secret"}
                OCIS_MACHINE_AUTH_API_KEY=${config.sops.placeholder."haddock/ocis/machine_auth_api_key"}
                OCIS_SERVICE_ACCOUNT_ID=${config.sops.placeholder."haddock/ocis/service_account_id"}
                OCIS_SERVICE_ACCOUNT_SECRET=${config.sops.placeholder."haddock/ocis/service_account_secret"}
                OCIS_SYSTEM_USER_API_KEY=${config.sops.placeholder."haddock/ocis/system_user_api_key"}
                OCIS_SYSTEM_USER_ID=${config.sops.placeholder."haddock/ocis/system_user_id"}
                OCIS_TRANSFER_SECRET=${config.sops.placeholder."haddock/ocis/transfer_secret"}
                STORAGE_USERS_MOUNT_ID=${config.sops.placeholder."haddock/ocis/storage_users_mount_id"}
                # OIDC
                WEB_OIDC_CLIENT_ID=${config.sops.placeholder.ocis-oidc-client-id_ocis}
            '';
            owner = cfg.user;
        };
        secrets = {
            "haddock/ocis/gateway_storage_users_mount_id".owner = cfg.user;
            "haddock/ocis/jwt_secret".owner = cfg.user;
            "haddock/ocis/machine_auth_api_key".owner = cfg.user;
            "haddock/ocis/service_account_id".owner = cfg.user;
            "haddock/ocis/service_account_secret".owner = cfg.user;
            "haddock/ocis/storage_users_mount_id".owner = cfg.user;
            "haddock/ocis/system_user_api_key".owner = cfg.user;
            "haddock/ocis/system_user_id".owner = cfg.user;
            "haddock/ocis/transfer_secret".owner = cfg.user;
            ocis-oidc-client-id_ocis = {
                key = "haddock/ocis/oidc_client_id";
                owner = cfg.user;
            };
            ocis-oidc-client-id_authelia = {
                key = "haddock/ocis/oidc_client_id";
                owner = "authelia-haddock";
            };
            ocis-oidc-client-secret_authelia = {
                key = "haddock/ocis/oidc_client_secret/authelia";
                owner = "authelia-haddock";
            };
        };
    };
}
