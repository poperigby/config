{ config, pkgs, ... }:

{
    sops.secrets = {
        "haddock/caddy/cloudflare_api_token" = {};
        "haddock/caddy/personal_email" = {};
    };

    sops.templates."Caddyfile".content = ''
        acme_dns cloudflare ${config.sops.placeholder."haddock/caddy/cloudflare_api_token"}
        email ${config.sops.placeholder."haddock/caddy/personal_email"}
    '';

    services.caddy = {
        enable = true;
        configFile = config.sops.templates."Caddyfile".path;
        package = (pkgs.callPackage ./custom-package.nix {
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
            vendorHash = "sha256-NoUbcMsdMVdUWbKlnoZ5Y34dQWtNa/OwrmZ0Cy4grVk=";
        });
    };


}
