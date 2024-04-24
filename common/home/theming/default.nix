{ inputs, pkgs, ... }:

{
    imports = [
        inputs.stylix.nixosModules.stylix
    ];

    stylix = {
        image = ./wallpaper.jpg;

        base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-light-hard.yaml";

        # cursor = {
        #     package = pkgs.gnome.adwaita-icon-theme;
        #     name = "Adwaita";
        # };

        fonts = {
            serif = {
                package = pkgs.noto-fonts;
                name = "Noto Serif";
            };
            sansSerif = {
                package = pkgs.noto-fonts;
                name = "Noto Sans";
            };
            monospace = {
                package = (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; });
                name = "JetBrainsMono Nerd Font Mono";
            };
            emoji = {
                package = pkgs.noto-fonts-emoji;
                name = "Noto Color Emoji";
            };
        };
    };
}
