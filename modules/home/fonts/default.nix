{ config, lib, pkgs, ... }:

let
    cfg = config.poperigby.fonts;
in
{
    options.poperigby.fonts.enable = lib.mkEnableOption "Enable font settings";

    config = lib.mkIf cfg.enable {
        fonts.fontconfig = {
            enable = true;
            defaultFonts = {
                sansSerif = [ "Noto Sans" ];
                # Make the serif font actually sans-serif for uniformity
                serif = [ "Noto Sans" ];
                monospace = [ "JetBrainsMono Nerd Font" ];
                emoji = [ "Noto Color Emoji" ];
            };
        };

        home.packages = with pkgs; [
            # Main font
            noto-fonts
            # Emoji font
            noto-fonts-color-emoji
            # Monospace font
            (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
        ];
    };
}
