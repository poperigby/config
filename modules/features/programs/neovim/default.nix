{ den, ... }:
{
    den.aspects.programs.provides.neovim.homeManager =
        {
            lib,
            pkgs,
            config,
            ...
        }:
        let
            nvim = lib.getExe config.programs.neovim.finalPackage;
        in
        {
            programs.neovim = {
                enable = true;
                defaultEditor = true;
                viAlias = true;
                vimAlias = true;
                extraPackages = with pkgs; [
                    bash-language-server
                    clang-tools
                    csharp-ls
                    harper
                    lua-language-server
                    luajitPackages.teal-language-server
                    nixd
                    nodejs
                    pyright
                    rust-analyzer
                    tinymist
                    typescript
                    vscode-langservers-extracted
                    yaml-language-server
                    slint-lsp
                ];
                initLua = ''
                    require("options")
                    require("misc")
                    require("mappings")
                    require("filetype")
                '';
            };

            home.sessionVariables = {
                MANPAGER = "${nvim} -c 'Man!' -o -";
                SYSTEMD_EDITOR = "${nvim}";
            };

            xdg.configFile."nvim" = {
                source = ./config;
                recursive = true;
            };
        };

    den.aspects.programs.provides.neovim-gui.homeManager =
        { lib, pkgs, ... }:
        {
            xdg.desktopEntries.nvim = {
                name = "Neovim";
                genericName = "Text Editor";
                exec = "${lib.getExe pkgs.wezterm} start nvim %F";
                terminal = false;
                type = "Application";
                icon = "nvim";
                categories = [
                    "Utility"
                    "TextEditor"
                ];
                mimeType = [ "text/plain" ];
            };
        };
}
