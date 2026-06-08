{ ... }:

{
    den.aspects.programs.provides.rio.homeManager = { pkgs, ... }: {
        programs.rio = {
            enable = true;
            package = pkgs.rio.overrideAttrs (old: {
                src = pkgs.fetchFromGitHub {
                    owner = "raphamorim";
                    repo = "rio";
                    rev = "refs/pull/1642/head";

                    hash = "sha256-+zCuhxKKxVKZ6cIXB9AJFihCNPkQNCIJCpqzptaqAg0=";
                };

                cargoHash = "";
            });
            themes.gruvbox-dark.colors = {
                background = "#32302f";
                foreground = "#ebdbb2";

                selection-background = "#504945";
                selection-foreground = "#ebdbb2";

                cursor = "#ebdbb2";

                black = "#32302f";
                red = "#cc241d";
                green = "#98971a";
                yellow = "#d79921";
                blue = "#458588";
                magenta = "#b16286";
                cyan = "#689d6a";
                white = "#a89984";

                light_black = "#928374";
                light_red = "#fb4934";
                light_green = "#b8bb26";
                light_yellow = "#fabd2f";
                light_blue = "#83a598";
                light_magenta = "#d3869b";
                light_cyan = "#8ec07c";
                light_white = "#ebdbb2";
            };
            settings = {
                theme = "gruvbox-dark";
                confirm-before-quit = false;
                window = {
                    opacity = 0.1;
                };
                fonts = {
                    family = "JetBrainsMono Nerd Font";
                    size = 15;
                    # Disable ligatures
                    features = [
                        "calt=0"
                        "clig=0"
                        "liga=0"
                    ];
                };
            };
        };

        home.packages = with pkgs; [
            nerd-fonts.jetbrains-mono
            noto-fonts-color-emoji
        ];
    };
}
