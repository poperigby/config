{ config, ... }:

let
  cfg = config.custom.services.rustical;
in
{
  custom.services.rustical = {
    enable = true;
    settings = {
      http = {
        host = "0.0.0.0";
        port = cfg.port;
      };
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
      frontend = {
        enabled = true;
        allow_password_login = false;
      };
      tracing.opentelemetry = false;
      dav_push.enabled = true;
      nextcloud_login.enabled = true;
      data_store.sqlite.db_url = "/var/lib/rustical/db.sqlite3";
    };
    secretsFile = config.sops.templates.rustical-secrets.path;
  };

  services.caddy.virtualHosts."dav.haddock.cc".extraConfig = ''
    reverse_proxy :${toString cfg.port}
  '';

  sops = {
    templates.rustical-secrets = {
      content = # bash
        ''
          RUSTICAL_OIDC__CLIENT_ID="${config.sops.placeholder.rustical-oidc-client-id_rustical}"
          RUSTICAL_OIDC__CLIENT_SECRET="${
            config.sops.placeholder."haddock/rustical/oidc_client_secret/rustical"
          }" 
        '';
      owner = cfg.user;
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
