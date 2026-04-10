# Sudo configuration.
{ den, ... }:
{
  den.aspects.security.provides.sudo.nixos =
    { pkgs, ... }:
    {
      security.sudo = {
        extraConfig = ''
          # We want sudo to be a little sassy
          Defaults insults
          # Show asterix when typing password
          Defaults pwfeedback
          # Keep our SYSTEMD_EDITOR variable
          Defaults env_keep += "SYSTEMD_EDITOR"
          # No lectures >:(
          Defaults lecture = never
        '';
        package = pkgs.sudo.override { withInsults = true; };
      };
    };
}

