{
    config,
    lib,
    pkgs,
    ...
}:

let
    inherit (lib) mkForce;

    rustical = config.services.rustical;
in
{
    services = {
        rustical = {
            enable = true;
            package = pkgs.rustical;
            settings = {
                http.bind = "localhost:4000";
                oidc = {
                    name = "Authelia";
                    issuer = "https://auth.haddock.cc";
                    claim_userid = "preferred_username";
                    scopes = [
                        "openid"
                        "profile"
                        "groups"
                    ];
                    allow_sign_up = true;
                };
            };
            environmentFiles = [ config.sops.templates.rustical-secrets.path ];
        };
        caddy.virtualHosts."dav.haddock.cc".extraConfig = ''
            reverse_proxy ${rustical.settings.http.bind}
        '';
        # https://lennart-k.github.io/rustical/setup/oidc
        authelia.oidcClients.haddock = [
            {
                client_name = "Rustical";
                client_id = config.sops.placeholder.rustical-oidc-client-id_authelia;
                client_secret = config.sops.placeholder."haddock/rustical/oidc_client_secret/authelia";
                public = false;
                authorization_policy = "one_factor";
                consent_mode = "implicit";
                scopes = [
                    "openid"
                    "profile"
                    "groups"
                ];
                token_endpoint_auth_method = "client_secret_basic";
                redirect_uris = [ "https://dav.haddock.cc/frontend/login/oidc/callback" ];
            }
        ];
    };

    users = {
        users.rustical = {
            isSystemUser = true;
            group = "rustical";
        };
        groups.rustical = { };
    };

    systemd.services.rustical.serviceConfig.DynamicUser = mkForce false;

    sops = {
        templates.rustical-secrets = {
            content = # bash
                ''
                    RUSTICAL_OIDC__CLIENT_ID="${config.sops.placeholder.rustical-oidc-client-id_rustical}"
                    RUSTICAL_OIDC__CLIENT_SECRET="${
                        config.sops.placeholder."haddock/rustical/oidc_client_secret/rustical"
                    }" 
                '';
            owner = "rustical";
        };
        secrets = {
            rustical-oidc-client-id_rustical = {
                key = "haddock/rustical/oidc_client_id";
                owner = "rustical";
            };
            rustical-oidc-client-id_authelia = {
                key = "haddock/rustical/oidc_client_id";
                owner = "authelia-haddock";
            };
            "haddock/rustical/oidc_client_secret/rustical".owner = "rustical";
            "haddock/rustical/oidc_client_secret/authelia".owner = "authelia-haddock";
        };
    };
}
