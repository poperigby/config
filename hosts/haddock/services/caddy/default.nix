{ pkgs, ... }:

{
    services.caddy = {
        enable = true;
        package = (pkgs.callPackage ./custom-package.nix {
            externalPlugins = [
                { name = "caddy-dns/porkbun"; repo = "github.com/caddy-dns/porkbun"; version = "4267f6797bf6543d7b20cdc8578a31764face4cf"; }
            ];
            vendorHash = "";  # Add this, as explained in https://github.com/NixOS/nixpkgs/pull/259275#issuecomment-1763478985 
        });
    };
}
