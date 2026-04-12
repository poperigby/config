{ pkgs, ... }:

{
    programs.neovim.plugins = [
        {
            plugin = pkgs.vimPlugins.which-key-nvim;
            type = "lua";
            config = # lua
                ''
                    require("which-key").setup({})
                '';
        }
    ];
}
