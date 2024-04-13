{ pkgs, ... }:

{
    programs.neovim = {
        enable = true;
        # Alias vi and vim to nvim
        viAlias = true;
        vimAlias = true;
        # Extra packages available to Neovim
        extraPackages = with pkgs; [
           gcc
        ];
    };

    home.file.".config/nvim" = {
        source = ./config;
        recursive = true;
    };

    # Make Neovim my manpager
    home.sessionVariables.MANPAGER = "${pkgs.neovim}/bin/nvim -c 'Man!' -o -";
}
