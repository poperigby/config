{ config, ... }:

let
  cfg = config.services.paperless;
in
{
  services = {
    paperless = {
      enable = true;
      passwordFile = config.sops.secrets."haddock/paperless/admin_password".path;
      settings = {
        PAPERLESS_DBHOST = "/run/postgresql";
        PAPERLESS_APPS = "allauth.socialaccount.providers.openid_connect";
        PAPERLESS_REDIRECT_LOGIN_TO_SSO = true;
        PAPERLESS_DISABLE_REGULAR_LOGIN = true;
      };
    };
    caddy.virtualHosts."paper.haddock.cc".extraConfig = ''
      import auth
      reverse_proxy :${toString cfg.port}
    '';
  };

  systemd.services.paperless-web.serviceConfig.EnvironmentFile =
    config.sops.templates.paperless-secrets.path;

  sops = {
    templates.paperless-secrets = {
      content = # json
        ''
          PAPERLESS_SOCIALACCOUNT_PROVIDERS='{
              "openid_connect": {
                  "OAUTH_PKCE_ENABLED": true,
                  "APPS": [
                      {
                          "provider_id": "authelia",
                          "name": "Authelia",
                          "client_id": "${config.sops.placeholder.paperless-oidc-client-id_paperless}",
                          "secret": "${
                            config.sops.placeholder."haddock/paperless/oidc_client_secret/paperless"
                          }",
                          "settings": {
                              "server_url": "https://auth.haddock.cc/.well-known/openid-configuration",
                              "token_auth_method": "client_secret_basic"
                          }
                      }
                  ]
              }
          }'
        '';
      owner = cfg.user;
    };
    secrets = {
      "haddock/paperless/admin_password".owner = cfg.user;
      "haddock/paperless/oidc_client_secret/authelia".owner = "authelia-haddock";
      "haddock/paperless/oidc_client_secret/paperless".owner = cfg.user;
      paperless-oidc-client-id_paperless = {
        key = "haddock/paperless/oidc_client_id";
        owner = cfg.user;
      };
      paperless-oidc-client-id_authelia = {
        key = "haddock/paperless/oidc_client_id";
        owner = "authelia-haddock";
      };
    };
  };
}
