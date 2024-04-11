{ pkgs, ... }:

{
    security.sudo = {
        # We want sudo to be a little sassy
        extraConfig = "Defaults insults";
        package = pkgs.sudo.override { withInsults = true; };
    };
}
