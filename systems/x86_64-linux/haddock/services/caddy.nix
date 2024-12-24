{
  config,
  inputs,
  system,
  ...
}:

let
  cfg = config.services.caddy;
in
{
  services.caddy = {
    enable = true;
    package = inputs.caddy.legacyPackages.${system}.caddy.withPlugins {
      plugins = [
        "github.com/caddy-dns/porkbun@v0.1.5"
      ];
      hash = "sha256-/23XIDPpF+i/F/5pCD/7ZHx4lxWU/HZBwi13eWc+h2w=";
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
