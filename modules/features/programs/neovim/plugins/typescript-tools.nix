{ pkgs, ... }:

{
    programs.neovim.plugins = [
        {
            plugin = pkgs.vimPlugins.typescript-tools-nvim;
            type = "lua";
            config = # lua
                ''
                    require("typescript-tools").setup({})
                '';
        }
    ];
}
