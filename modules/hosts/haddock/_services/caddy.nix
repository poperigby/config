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
            ];
            hash = "sha256-MlKX2obWac+jP4j9UHFMxsY/DRaqw9JCVAdI7erhFwo=";
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
            '';
    };

    # Allow HTTP/S
    networking.firewall.allowedTCPPorts = [
        80
        443
    ];

    # Read secrets into environment variables, that we can then reference with {env.<SECRET_NAME>}
    systemd.services.caddy.serviceConfig.EnvironmentFile = config.sops.templates.caddy-secrets.path;

    # Bind mount of the log directory that CrowdSec can read. Yes, this is horrific.
    # fileSystems."/var/log/caddy-crowdsec" = {
    #     device = "/var/log/caddy";
    #     fsType = "fuse.bindfs";
    #     options = [
    #         "ro" # Read-only
    #         "force-user=crowdsec" # All files appear owned by CrowdSec
    #         "force-group=crowdsec"
    #         "create-for-user=crowdsec"
    #         "create-for-group=crowdsec"
    #         "create-with-perms=0440"
    #     ];
    # };

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
