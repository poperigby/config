{ config, lib, pkgs, ... }:

let
    cfg = config.poperigby.programs.neovim;
    nvim = "${config.programs.neovim.finalPackage}/bin/nvim";
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
                # Language servers
                lua-language-server
                nixd
                poperigby.harper
                rust-analyzer
            ];
            plugins = [
                # All other plugins are managed by lazy-nvim
                pkgs.vimPlugins.lazy-nvim
            ];
        };

        home.sessionVariables = {
            # Make Neovim my pager for the man command
            MANPAGER = "${nvim} -c 'Man!' -o -";
            # Make Neovim my systemd editor
            SYSTEMD_EDITOR = "${nvim}";
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


        # Setup plugins with Lazy during activation
        home.activation.neovim = lib.home-manager.hm.dag.entryAfter [ "linkGeneration" ] # bash
        ''
            run ${nvim} --headless "+Lazy! restore" +qa
        '';
    };
}
