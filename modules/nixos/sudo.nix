{ pkgs, ... }:

{
    security.sudo = {
        extraConfig = ''
            Default insults
        '';
        package = pkgs.sudo.override { withInsults = true; };
    };
}
