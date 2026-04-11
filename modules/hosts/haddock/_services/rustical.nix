{
    config,
    lib,
    pkgs,
    ...
}:

let
    inherit (lib) mkForce;

    cfg = config.services.rustical;
in
{
    services = {
        rustical = {
            enable = true;
            package = pkgs.rustical;
            settings = {
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
            environmentFile = config.sops.templates.rustical-secrets.path;
        };
        caddy.virtualHosts."dav.haddock.cc".extraConfig = ''
            reverse_proxy :${toString cfg.settings.http.port}
        '';
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
