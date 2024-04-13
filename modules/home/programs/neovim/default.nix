{ pkgs, ... }:

{
    programs.neovim = {
        enable = true;
        # Alias vi and vim to neovim
        viAlias = true;
        vimAlias = true;
    };

    # Make Neovim my manpager
    home.sessionVariables.MANPAGER = "${pkgs.neovim} -c 'Man!' -o -";
}
