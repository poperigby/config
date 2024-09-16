{ config, lib, pkgs, ... }:

let
    inherit (lib)
        getExe
        mkEnableOption
        mkIf
    ;

    cfg = config.poperigby.programs.neovim;
    nvim = getExe config.programs.neovim.finalPackage;
in
{
    options.poperigby.programs.neovim.enable = mkEnableOption "Neovim";

    config = mkIf cfg.enable {
        programs.neovim = {
            enable = true;
            # Set EDITOR to nvim
            defaultEditor = true;
            # Alias vi and vim to nvim
            viAlias = true;
            vimAlias = true;
            # Extra packages available to Neovim
            extraPackages = with pkgs; [
                # Language servers
                bash-language-server
                clang-tools
                harper
                lua-language-server
                nixd
                ruff
                rust-analyzer
            ];
            extraLuaConfig = # lua
            ''
                require("options")
                require("misc")
                require("mappings")
                require("filetype")
            '';
        };

        home.sessionVariables = {
            # Make Neovim my pager for the man command
            MANPAGER = "${nvim} -c 'Man!' -o -";
            # Make Neovim my systemd editor
            SYSTEMD_EDITOR = "${nvim}";
        };

        xdg.configFile = {
            # Symlink Neovim config to ~/.config/nvim/lua
            "nvim/lua" = {
                source = ./config;
                recursive = true;
            };
        };
    };
}
