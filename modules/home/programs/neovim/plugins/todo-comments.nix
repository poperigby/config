{ pkgs, ... }:

{
    programs.neovim.plugins = with pkgs.vimPlugins; [
        {
            plugin = todo-comments-nvim;
            type = "lua";
            config = # lua
            ''
                require("todo-comments").setup({})
            '';
        }
        plenary-nvim
    ];
}
