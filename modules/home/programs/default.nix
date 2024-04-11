{ inputs, pkgs, ... }:

{
    imports = [
        ./bat.nix
        ./eza.nix
        ./firefox.nix
        ./neovim
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
        sops
        thefuck
        inputs.nh.packages."${pkgs.system}".nh
        (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];
}
