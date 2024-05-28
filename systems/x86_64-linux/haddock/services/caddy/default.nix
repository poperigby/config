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
                    name = "caddy-dns/cloudflare";
                    repo = "github.com/caddy-dns/cloudflare";
                    version = "737bf003fe8af81814013a01e981dc8faea44c07";
                }
                {
                    name = "hslatman/caddy-crowdsec-bouncer";
                    repo = "github.com/hslatman/caddy-crowdsec-bouncer";
                    version = "2f58c9f6be2c98b37d07a48c5dfaaf8a7178ac0f";
                }
            ];
            # Add this, as explained in https://github.com/NixOS/nixpkgs/pull/259275#issuecomment-1763478985
            vendorHash = "sha256-wipTwYjIQ4YQB0DsTGQh5vbPeueem9vjwpy41frmR18=";
        });
        globalConfig = ''
            (auth) {
                forward_auth localhost:9091 {
                    copy_headers Remote-User Remote-Groups Remote-Email Remote-Name
                }
            }

            # TODO: Uncomment when on bare metal
            # acme_dns cloudflare {env.CLOUDFLARE_API_TOKEN}
            email {env.EMAIL}
        '';
    };

    # Read secrets into environment variables, that we can then reference with {env.SECRET_NAME}
    systemd.services.caddy.serviceConfig.EnvironmentFile = config.sops.templates.caddy-secrets.path;

    sops = {
        templates.caddy-secrets = {
            owner = cfg.user;
            content = ''
                CLOUDFLARE_API_TOKEN="${config.sops.placeholder."haddock/caddy/cloudflare_api_token"}"
                EMAIL="${config.sops.placeholder.cassidy-email-caddy}"
            '';
        };
        secrets = {
            "haddock/caddy/cloudflare_api_token" = {};
             cassidy-email-caddy = {
                 owner = cfg.user;
                 key = "common/users/cassidy/email";
             };
        };
    };
}
