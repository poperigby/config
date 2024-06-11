{ config, inputs, lib, ... }:

let
    cfg = config.poperigby.desktops.sway;
    colors = config.colorScheme.palette;
    fonts = config.fonts.fontconfig.defaultFonts;
in
{
    imports = [ inputs.nix-colors.homeManagerModules.default ];

    config = lib.mkIf cfg.enable {
        wayland.windowManager.sway = {
            config = {
                fonts = {
                   names = fonts.sansSerif;
                   style = "normal";
                   size = 11.0;
                };
                gaps.inner = 5;
                colors = {
                    background = "#${colors.base00}";
                    focused = rec {
                        background = "#${colors.base02}";
                        border = "#${colors.base01}";
                        childBorder = border;
                        indicator = "#${colors.base01}";
                        text = "#${colors.base07}";
                    };
                    focusedInactive = rec {
                        background = "#${colors.base00}";
                        border = "#${colors.base02}";
                        childBorder = border;
                        indicator = "#${colors.base02}";
                        text = "#${colors.base06}";
                    };
                    placeholder = {
                        background = "#${colors.base06}";
                        # Ignored
                        border = "#000000";
                        childBorder = "#${colors.base02}";
                        # Ignored
                        indicator = "#000000";
                        text = "#${colors.base07}";
                    };
                    unfocused = rec {
                        background = "#${colors.base00}";
                        border = "#${colors.base02}";
                        childBorder = border;
                        indicator = "#${colors.base02}";
                        text = "#${colors.base06}";
                    };
                    urgent = rec {
                        background = "#${colors.base08}";
                        border = "#${colors.base06}";
                        childBorder = border;
                        indicator = "#${colors.base06}";
                        text = "#${colors.base07}";
                    };
                };
            };
            # SwayFX settings will have to go here
            extraConfig = ''
                corner_radius 10
            '';
        };
    };
}
