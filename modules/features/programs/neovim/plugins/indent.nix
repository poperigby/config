{ pkgs, ... }:

{
    programs.neovim.plugins = [
        {
            plugin = pkgs.vimPlugins.blink-indent;
            type = "lua";
            config = # lua
                ''
                    require("blink.indent").setup({})
                '';
        }
    ];
}
