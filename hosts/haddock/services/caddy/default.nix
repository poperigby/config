{ pkgs, ... }:

{
    services.caddy = {
        enable = true;
        package = (pkgs.callPackage ./custom-package.nix {
            externalPlugins = [
                {
                    name = "caddy-dns/cloudflare";
                    repo = "github.com/caddy-dns/cloudflare";
                    version = "2fa0c8ac916ab13ee14c836e59fec9d85857e429";
                }
                {
                    name = "hslatman/caddy-crowdsec-bouncer";
                    repo = "github.com/hslatman/caddy-crowdsec-bouncer";
                    version = "054d8c95c6dd2525352791f882c7bf96368844b9";
                }
            ];
            # Add this, as explained in https://github.com/NixOS/nixpkgs/pull/259275#issuecomment-1763478985
            vendorHash = "sha256-Uy2vq+mEIUs5MMVvLy6G7A308MCjoT2SqKv/I0yDK5w=";
        });
    };
}
