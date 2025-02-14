{
  config,
  pkgs,
  ...
}:

let
  cfg = config.services.caddy;
in
{
  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = [
        "github.com/caddy-dns/porkbun@v0.2.1"
      ];
      hash = "sha256-ayd1WnjBjQOIXtiCkR/aWML2Nc4eRyuTugsjHXOU5uQ=";
    };
    email = "poperigby@mailbox.org";
    globalConfig = ''
      acme_dns porkbun {
          api_key {env.PORKBUN_API_KEY}
          api_secret_key {env.PORKBUN_API_SECRET_KEY}
      }
      # Make the main log more human readable
      log stdout_logger {
          output stdout
          format console
          exclude http.log.access
      }
    '';
  };

  # Allow HTTP/S
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  # Read secrets into environment variables, that we can then reference with {env.<SECRET_NAME>}
  systemd.services.caddy.serviceConfig.EnvironmentFile = config.sops.templates.caddy-secrets.path;

  sops = {
    templates.caddy-secrets = {
      content = ''
        PORKBUN_API_KEY="${config.sops.placeholder."haddock/caddy/porkbun_api_key"}"
        PORKBUN_API_SECRET_KEY="${config.sops.placeholder."haddock/caddy/porkbun_api_secret_key"}"
      '';
      owner = cfg.user;
    };
    secrets = {
      "haddock/caddy/porkbun_api_key".owner = cfg.user;
      "haddock/caddy/porkbun_api_secret_key".owner = cfg.user;
    };
  };
}
