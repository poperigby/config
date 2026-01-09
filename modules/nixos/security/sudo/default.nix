{
    config,
    lib,
    pkgs,
    ...
}:

let
    inherit (lib)
        mkEnableOption
        mkIf
        ;

    cfg = config.custom.security.sudo;
in
{
    options.custom.security.sudo.enable = mkEnableOption "sudo tweaks";

    config = mkIf cfg.enable {
        security.sudo = {
            extraConfig = # bash
                ''
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
