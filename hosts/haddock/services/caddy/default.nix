{ pkgs, ... }:

{
    services.caddy = {
        enable = true;
        package = (pkgs.callPackage "${builtins.fetchurl https://raw.githubusercontent.com/jpds/nixpkgs/a33b02fa9d664f31dadc8a874eb1a5dbaa9f4ecf/pkgs/servers/caddy/default.nix}" {
            externalPlugins = [
                { name = "caddy-dns/porkbun"; repo = "github.com/caddy-dns/porkbun"; version = "4267f6797bf6543d7b20cdc8578a31764face4cf"; }
            ];
            vendorHash = "";  # Add this, as explained in https://github.com/NixOS/nixpkgs/pull/259275#issuecomment-1763478985 
        });
    };
}
