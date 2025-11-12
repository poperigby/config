{ pkgs, ... }:

{
    programs.neovim.plugins = [
        {
            plugin = pkgs.vimPlugins.blink-pairs;
            type = "lua";
            config = # lua
                ''
                    require("blink.pairs").setup({})
                '';
        }
    ];
}
