{ config, inputs, lib, ... }:

let
    cfg = config.poperigby.programs.zathura;
    colors = config.colorScheme.palette;
in
{
    options.poperigby.programs.zathura.enable = lib.mkEnableOption "Enable Zathura PDF reader";

    imports = [ inputs.nix-colors.homeManagerModules.default ];

    config = lib.mkIf cfg.enable {
        programs.zathura = {
            enable = true;
            options = {
                ## Misc.
                # Use system clipboard
                selection-clipboard = "clipboard";
                ## Theming
                default-bg = "#${colors.base00}";
            };
        };

        xdg.mimeApps.defaultApplications = {
            "application/pdf" = "zathura.desktop";
        };
    };
}
