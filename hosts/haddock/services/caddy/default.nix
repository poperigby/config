{ pkgs, ... }:

{
    services.caddy = {
        enable = true;
        package = (pkgs.callPackage ./custom-package.nix {
            plugins = [
                "github.com/caddy-dns/cloudflare"
                "github.com/hslatman/caddy-crowdsec-bouncer/http"
            ];
            vendorSha256 = "0000000000000000000000000000000000000000000000000000";
        });
    };
}
