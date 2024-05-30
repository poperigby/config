{ config, lib, pkgs, ... }:

let
    cfg = config.poperigby.system.fonts;
in
{
    options.poperigby.system.fonts.enable = lib.mkEnableOption "Enable font settings";

    config = lib.mkIf cfg.enable {
        fonts = {
            packages = with pkgs; [
                # Main font
                noto-fonts
                # Monospace font
                (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
            ];
            fontconfig = {
                defaultFonts = {
                    sansSerif = [ "Noto Sans" ];
                    # Make the serif font actually sans-serif for uniformity
                    serif = [ "Noto Sans" ];
                    monospace = [ "JetBrainsMono Nerd Font" ];
                    emoji = [ "Noto Color Emoji" ];
                };
            };
        };
    };
}
