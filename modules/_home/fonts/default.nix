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

    cfg = config.custom.fonts;
in
{
    options.custom.fonts.enable = mkEnableOption "font settings";

    config = mkIf cfg.enable {
        fonts.fontconfig = {
            enable = true;
            defaultFonts = {
                sansSerif = [
                    "Noto Sans"
                    "Noto Sans CJK"
                ];
                # Make the serif font actually sans-serif for uniformity
                serif = [
                    "Noto Sans"
                    "Noto Sans CJK"
                ];
                monospace = [ "JetBrainsMono Nerd Font" ];
                emoji = [ "Noto Color Emoji" ];
            };
        };
        home.packages = with pkgs; [
            # Latin font
            noto-fonts
            # Chinese, Japanese, and Korean font
            noto-fonts-cjk-sans
            # Emoji font
            noto-fonts-color-emoji
            # Monospace font
            nerd-fonts.jetbrains-mono
        ];
    };
}
