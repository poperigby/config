{ inputs, pkgs, ... }:

{
    imports = [
        ./bat.nix
        ./eza.nix
        ./firefox.nix
        ./fzf.nix
        ./git.nix
        ./mangohud.nix
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
        just
        lazygit
        ripgrep
        sops
        vimv-rs
        inputs.nh.packages."${pkgs.system}".nh
    ];
}
