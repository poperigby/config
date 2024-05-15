{ pkgs, ... }:

{
    programs.neovim = {
        enable = true;
        # Set EDITOR to nvim
        defaultEditor = true;
        # Alias vi and vim to nvim
        viAlias = true;
        vimAlias = true;
        # Extra packages available to Neovim
        extraPackages = with pkgs; [
            # For Rust packages
            cargo
            # TreeSitter needs this to install parsers
            gcc
            # Some plugins need this to install
            gnumake
        ];
    };

    # Symlink Neovim config to ~/.config/nvim
    home.file.".config/nvim" = {
        source = ./config;
        recursive = true;
    };

    # Make Neovim my manpager
    home.sessionVariables.MANPAGER = "${pkgs.neovim}/bin/nvim -c 'Man!' -o -";
}
