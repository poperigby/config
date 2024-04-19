{ inputs, pkgs, ... }:

{
    imports = [
        ./bat.nix
        ./eza.nix
        ./firefox.nix
        ./git.nix
        ./neovim
        ./tealdeer.nix
        ./wezterm
        ./yazi
    ];

    # Programs that don't require any configuration
    home.packages = with pkgs; [
        asciinema
        bottom
        fd
        fzf
        just
        lazygit
        ripgrep
        sops
        vimv-rs
        inputs.nh.packages."${pkgs.system}".nh
        (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];
}
