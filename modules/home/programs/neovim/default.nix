{ config, lib, pkgs, ... }:

let
    cfg = config.poperigby.programs.neovim;
in
{
    options.poperigby.programs.neovim.enable = lib.mkEnableOption "Enable Neovim";

    config = lib.mkIf cfg.enable {
        programs.neovim = {
            enable = true;
            # Set EDITOR to nvim
            defaultEditor = true;
            # Alias vi and vim to nvim
            viAlias = true;
            vimAlias = true;
            # Extra packages available to Neovim
            extraPackages = with pkgs; [
                # TreeSitter needs this to install parsers
                gcc
                # Some plugins/tools need these to install
                cargo
                gnumake
                nodePackages.npm
                unzip
            ];
        };

        # Symlink Neovim config to ~/.config/nvim
        home.file.".config/nvim" = {
            source = ./config;
            recursive = true;
        };

        # Make Neovim my manpager
        home.sessionVariables.MANPAGER = "${pkgs.neovim}/bin/nvim -c 'Man!' -o -";
    };
}
