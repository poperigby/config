{ config, lib, pkgs, ... }:

let
  cfg = config.poperigby.security.sudo;
in
{
    options.poperigby.security.sudo.enable = lib.mkEnableOption "Enable sudo tweaks";

    config = lib.mkIf cfg.enable {
        security.sudo = {
            # We want sudo to be a little sassy
            extraConfig = "Defaults insults,pwfeedback";
            package = pkgs.sudo.override { withInsults = true; };
        };
    };
}
