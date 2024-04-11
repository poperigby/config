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
      # # It is sometimes useful to fine-tune packages, for example, by applying
      # # overrides. You can do that directly here, just don't forget the
      # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
      # # fonts?
      # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })
    ];
}
