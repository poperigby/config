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
                # We don't need the builtin identitiy provider or manager
                # OCIS_EXCLUDE_RUN_SERVICES = "idp,idm";
                # OIDC
                # OCIS_OIDC_ISSUER = "https://auth.haddock.cc";
                # PROXY_OIDC_REWRITE_WELLKNOWN = "true";
                # PROXY_AUTOPROVISION_ACCOUNTS = "true";
                # Mail
                NOTIFICATIONS_SMTP_HOST = "smtp.sendgrid.net";
                NOTIFICATIONS_SMTP_PORT = "587";
                NOTIFICATIONS_SMTP_SENDER = "ocis@haddock.cc";
                NOTIFICATIONS_SMTP_USERNAME = "apikey";
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
                # IDs & passwords
                GATEWAY_STORAGE_USERS_MOUNT_ID=${config.sops.placeholder."haddock/ocis/gateway_storage_users_mount_id"}
                GRAPH_APPLICATION_ID=${config.sops.placeholder."haddock/ocis/graph_application_id"}
                IDM_IDPSVC_PASSWORD=${config.sops.placeholder."haddock/ocis/idm_idpsvc_password"}
                IDM_REVASVC_PASSWORD=${config.sops.placeholder."haddock/ocis/idm_revasvc_password"}
                IDM_SVC_PASSWORD=${config.sops.placeholder."haddock/ocis/idm_svc_password"}
                OCIS_JWT_SECRET=${config.sops.placeholder."haddock/ocis/jwt_secret"}
                OCIS_LDAP_BIND_PASSWORD=${config.sops.placeholder."haddock/ocis/ldap_bind_password"}
                OCIS_MACHINE_AUTH_API_KEY=${config.sops.placeholder."haddock/ocis/machine_auth_api_key"}
                OCIS_SERVICE_ACCOUNT_ID=${config.sops.placeholder."haddock/ocis/service_account_id"}
                OCIS_SERVICE_ACCOUNT_SECRET=${config.sops.placeholder."haddock/ocis/service_account_secret"}
                OCIS_SYSTEM_USER_API_KEY=${config.sops.placeholder."haddock/ocis/system_user_api_key"}
                OCIS_SYSTEM_USER_ID=${config.sops.placeholder."haddock/ocis/system_user_id"}
                OCIS_TRANSFER_SECRET=${config.sops.placeholder."haddock/ocis/transfer_secret"}
                STORAGE_USERS_MOUNT_ID=${config.sops.placeholder."haddock/ocis/storage_users_mount_id"}
                # OIDC
                # WEB_OIDC_CLIENT_ID=${config.sops.placeholder.ocis-oidc-client-id_ocis}
                # Mail
                NOTIFICATIONS_SMTP_PASSWORD=${config.sops.placeholder.sendgrid-api-key_ocis}
            '';
            owner = cfg.user;
        };
        secrets = {
            "haddock/ocis/gateway_storage_users_mount_id".owner = cfg.user;
            "haddock/ocis/graph_application_id".owner = cfg.user;
            "haddock/ocis/jwt_secret".owner = cfg.user;
            "haddock/ocis/ldap_bind_password".owner = cfg.user;
            "haddock/ocis/machine_auth_api_key".owner = cfg.user;
            "haddock/ocis/service_account_id".owner = cfg.user;
            "haddock/ocis/service_account_secret".owner = cfg.user;
            "haddock/ocis/storage_users_mount_id".owner = cfg.user;
            "haddock/ocis/system_user_api_key".owner = cfg.user;
            "haddock/ocis/system_user_id".owner = cfg.user;
            "haddock/ocis/transfer_secret".owner = cfg.user;
            "haddock/ocis/idm_idpsvc_password".owner = cfg.user;
            "haddock/ocis/idm_revasvc_password".owner = cfg.user;
            "haddock/ocis/idm_svc_password".owner = cfg.user;
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
            sendgrid-api-key_ocis = {
                key = "common/sendgrid/api_key";
                owner = cfg.user;
            };
        };
    };
}
