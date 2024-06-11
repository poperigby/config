# TODO: Don't I need to open the firewall ports?

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
            vendorHash = "";
        });
        globalConfig = ''
            email {env.EMAIL}
            acme_dns porkbun {
                api_key {env.PORKBUN_API_KEY}
                api_secret_key {env.PORKBUN_API_SECRET_KEY}
            }
        '';
        extraConfig = ''
            (auth) {
                # Taken from https://www.authelia.com/integration/proxies/caddy/#subdomain
                forward_auth localhost:9091 {
                    uri /api/authz/forward-auth
                    copy_headers Remote-User Remote-Groups Remote-Email Remote-Name
                }
            }
        '';
    };

    # Read secrets into environment variables, that we can then reference with {env.SECRET_NAME}
    systemd.services.caddy.serviceConfig.EnvironmentFile = config.sops.templates.caddy-secrets.path;

    sops = {
        templates.caddy-secrets = {
            owner = cfg.user;
            content = ''
                PORKBUN_API_KEY="${config.sops.placeholder."haddock/caddy/porkbun_api_key"}"
                PORKBUN_SECRET_KEY="${config.sops.placeholder."haddock/caddy/porkbun_secret_key"}"
                EMAIL="${config.sops.placeholder.cassidy-email-caddy}"
            '';
        };
        secrets = {
            "haddock/caddy/porkbun_api_key".owner = cfg.user;
            "haddock/caddy/porkbun_secret_key".owner = cfg.user;
             cassidy-email-caddy = {
                 owner = cfg.user;
                 key = "common/users/cassidy/email";
             };
        };
    };
}
