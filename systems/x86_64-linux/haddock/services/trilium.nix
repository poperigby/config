{ config, ... }:

let
  cfg = config.services.trilium-server;
  domain = "notes.haddock.cc";
in
{
  services = {
    trilium-server = {
      enable = true;
      instanceName = "Haddock";
    };
    caddy.virtualHosts.${domain}.extraConfig = ''
      import auth
      reverse_proxy :${toString cfg.port}
    '';
  };

  # systemd.services.trilium-server = {
  #   environment = {
  #     TRILIUM_OAUTH_BASE_URL = "https://${domain}";
  #     TRILIUM_OAUTH_ISSUER_BASE_URL = "https://auth.haddock.cc";
  #     TRILIUM_OAUTH_ISSUER_NAME = "Authelia";
  #     TRILIUM_OAUTH_ISSUER_ICON = "https://www.authelia.com/images/branding/logo-cropped.png ";
  #   };
  #   serviceConfig.EnvironmentFile = config.sops.templates.trilium-secrets.path;
  # };
  #
  # sops = {
  #   templates.trilium-secrets = {
  #     content = # bash
  #       ''
  #         TRILIUM_OAUTH_CLIENT_ID=${config.sops.placeholder.trilium-oidc-client-id_trilium}
  #         TRILIUM_OAUTH_CLIENT_SECRET=${config.sops.placeholder."haddock/trilium/oidc_client_secret/trilim"}
  #       '';
  #     owner = cfg.user;
  #   };
  #   secrets = {
  #     trilium-oidc-client-id_trilium = {
  #       key = "haddock/trilium/oidc_client_id";
  #       owner = "trilium";
  #     };
  #     trilium-oidc-client-id_authelia = {
  #       key = "haddock/trilium/oidc_client_id";
  #       owner = "authelia-haddock";
  #     };
  #     "haddock/trilium/oidc_client_secret/trilium".owner = "trilium";
  #     "haddock/trilium/oidc_client_secret/authelia".owner = "authelia-haddock";
  #   };
  # };
}
