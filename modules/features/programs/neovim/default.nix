{ inputs, ... }:
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
            imports = [
                (inputs.import-tree ./_plugins)
            ];

            programs.neovim = {
                enable = true;
                defaultEditor = true;
                viAlias = true;
                vimAlias = true;
                withRuby = false;
                withPython3 = false;
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
                # Plugins that require no configuration
                plugins = with pkgs.vimPlugins; [
                    helpview-nvim
                    mkdir-nvim
                    none-ls-nvim
                    nvim-ts-autotag
                    vim-zscript
                    fluent-vim
                ];
            };

            home.sessionVariables = {
                MANPAGER = "${nvim} -c 'Man!' -o -";
                SYSTEMD_EDITOR = "${nvim}";
            };

            xdg.configFile."nvim/lua" = {
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
