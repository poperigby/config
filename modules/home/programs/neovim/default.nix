{ pkgs, ... }:

{
    programs.neovim = {
        enable = true;
        # Alias vi and vim to neovim
        viAlias = true;
        vimAlias = true;
    };

    home.file.".config/nvim" = {
        source = ./config;
        recursive = true;
    };

    # Make Neovim my manpager
    home.sessionVariables.MANPAGER = "${pkgs.neovim}/bin/nvim -c 'Man!' -o -";
}
