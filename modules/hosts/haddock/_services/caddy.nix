{
    config,
    privateInfo,
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
                "github.com/caddy-dns/porkbun@v0.3.1"
                "github.com/mholt/caddy-l4@v0.1.0"
            ];
            hash = "sha256-Qbn2vdamLUr0eoXZ2oTq6Jedqni8fh2ZRxOHDi7rpC4=";
        };
        email = privateInfo.poperigby.email;
        globalConfig = # caddy
            ''
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

                # Duplicate access logs from every HTTP virtual host into a
                # shared JSON file for CrowdSec to parse.
                log crowdsec {
                    include http.log.access
                    output file /var/log/caddy/crowdsec.log {
                        mode 0640
                    }
                    format json
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
