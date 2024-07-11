{ config, pkgs, ... }:
let
    cfg = config.services.caddy;
in
{
    services.caddy = {
        enable = true;
        package = (pkgs.callPackage ./package.nix {
            externalPlugins = [
                {
                    name = "caddy-dns/porkbun";
                    repo = "github.com/caddy-dns/porkbun";
                    version = "v0.1.5";
                }
                {
                    name = "hslatman/caddy-crowdsec-bouncer";
                    repo = "github.com/hslatman/caddy-crowdsec-bouncer";
                    version = "2f58c9f6be2c98b37d07a48c5dfaaf8a7178ac0f";
                }
            ];
            # Add this, as explained in https://github.com/NixOS/nixpkgs/pull/259275#issuecomment-1763478985
            vendorHash = "sha256-xeO2YHIVAcsdowCUMoifr49Ncynz2QA3WPTCpIuILnk=";
        });
        globalConfig = ''
            email poperigby@mailbox.org
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
        # Virtual host for testing
        virtualHosts."haddock.cc".extraConfig = ''
            respond "Hello, world!"
        '';
    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];

    systemd.services.caddy.serviceConfig = {
        # Read secrets into environment variables, that we can then reference with {env.<SECRET_NAME>}
        EnvironmentFile = config.sops.templates.caddy-secrets.path;
    };

    sops = {
        templates.caddy-secrets = {
            owner = cfg.user;
            content = ''
                PORKBUN_API_KEY="${config.sops.placeholder."haddock/caddy/porkbun_api_key"}"
                PORKBUN_API_SECRET_KEY="${config.sops.placeholder."haddock/caddy/porkbun_api_secret_key"}"
            '';
        };
        secrets = {
            "haddock/caddy/porkbun_api_key".owner = cfg.user;
            "haddock/caddy/porkbun_api_secret_key".owner = cfg.user;
        };
    };
}
