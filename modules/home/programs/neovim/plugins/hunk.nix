{ pkgs, ... }:

{
    programs.neovim.plugins = with pkgs.vimPlugins; [
        {
            plugin = hunk-nvim;
            type = "lua";
            config = # lua
                ''
                    require("hunk").setup({})
                '';
        }
        mini-icons
    ];
}
