{ inputs, pkgs, ... }:

{
    imports = [
        ./bat.nix
        ./bottom.nix
        ./eza.nix
        ./firefox.nix
        ./fzf.nix
        ./git.nix
        ./neovim
        ./tealdeer.nix
        ./wezterm
        ./yazi.nix
    ];

    # Programs that don't require any configuration
    home.packages = with pkgs; [
        asciinema
        fd
        just
        lazygit
        ripgrep
        sops
        vimv-rs
        inputs.nh.packages."${pkgs.system}".nh
    ];
}
