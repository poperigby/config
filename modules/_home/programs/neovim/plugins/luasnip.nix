{ pkgs, ... }:

{
    programs.neovim.plugins = with pkgs.vimPlugins; [
        {
            plugin = luasnip;
            type = "lua";
            config = # lua
                ''
                    require("luasnip.loaders.from_vscode").lazy_load()
                '';
        }
        friendly-snippets
    ];
}
