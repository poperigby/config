{
  config,
  ...
}:

let
  cfg = config.custom.services.filebrowser;
in
{
  custom.services.filebrowser = {
    enable = true;
    settings = {
      server = {
        port = 8282;
        sources = [
          {
            path = "/mnt/media/files";
            config.createUserDir = true;
          }
        ];
      };
      auth.methods = {
        password.enabled = false;
        oidc = {
          enabled = true;
          issuerUrl = "https://auth.haddock.cc";
          scopes = "email openid profile";
          createUser = true;
          adminGroup = "lldap_admin";
        };
      };
    };
    secretsFile = config.sops.templates.filebrowser-secrets.path;
  };
  services.caddy.virtualHosts."files.haddock.cc".extraConfig = ''
    import auth
    reverse_proxy :${toString cfg.settings.server.port}
  '';

  sops = {
    templates.filebrowser-secrets = {
      content = # bash
        ''
          FILEBROWSER_OIDC_CLIENT_ID=${config.sops.placeholder.filebrowser-oidc-client-id_filebrowser}
          FILEBROWSER_OIDC_CLIENT_SECRET=${
            config.sops.placeholder."haddock/filebrowser/oidc_client_secret/filebrowser"
          }                        
        '';
      owner = "filebrowser";
    };
    secrets = {
      filebrowser-oidc-client-id_filebrowser = {
        key = "haddock/filebrowser/oidc_client_id";
        owner = "filebrowser";
      };
      filebrowser-oidc-client-id_authelia = {
        key = "haddock/filebrowser/oidc_client_id";
        owner = "authelia-haddock";
      };
      "haddock/filebrowser/oidc_client_secret/filebrowser".owner = "filebrowser";
      "haddock/filebrowser/oidc_client_secret/authelia".owner = "authelia-haddock";
    };
  };
}
