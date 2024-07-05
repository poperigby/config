{ config, lib, pkgs, ... }:

let
    cfg = config.poperigby.programs.neovim;
    nvimDir = "${config.poperigby.configDir}/modules/home/programs/neovim";
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
            plugins = [
                # All other plugins are managed by lazy-nvim
                pkgs.vimPlugins.lazy-nvim
            ];
        };

        xdg.configFile = {
            # Symlink Neovim config to ~/.config/nvim
            "nvim" = {
                source = ./config;
                recursive = true;
            };
            # Raw symlink to the plugin manager lock file, so that it stays writeable
            "nvim/lazy-lock.json".source = config.lib.file.mkOutOfStoreSymlink "${nvimDir}/lazy-lock.json";
        };

        # Make Neovim my pager for the man command
        home.sessionVariables.MANPAGER = "${pkgs.neovim}/bin/nvim -c 'Man!' -o -";
    };
}
