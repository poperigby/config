{ pkgs, ... }:

{
    imports = [
        ./eza.nix
        ./firefox.nix
        ./tealdeer.nix
        ./wezterm
        ./yazi.nix
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
