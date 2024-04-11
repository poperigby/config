{ pkgs, ... }:

{
    imports = [
        ./eza.nix
        ./firefox.nix
        ./wezterm
    ];

    # Programs that don't require any configuration
    home.packages = with pkgs; [
        asciinema
        bottom
        fzf
        lazygit
        ripgrep
        (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];
}
