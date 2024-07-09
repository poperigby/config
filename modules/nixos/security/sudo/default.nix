{ config, lib, pkgs, ... }:

let
  cfg = config.poperigby.security.sudo;
in
{
    options.poperigby.security.sudo.enable = lib.mkEnableOption "Enable sudo tweaks";

    config = lib.mkIf cfg.enable {
        security.sudo = {
            extraConfig = ''
                # We want sudo to be a little sassy
                Defaults insults
                # Show asterix when typing password
                Defaults pwfeedback
                # Keep our SYSTEMD_EDITOR variable
                Defaults env_keep += "SYSTEMD_EDITOR"
            '';
            package = pkgs.sudo.override { withInsults = true; };
        };
    };
}
