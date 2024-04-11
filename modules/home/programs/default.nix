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
        fd
        fzf
        lazygit
        ripgrep
        (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];
}
