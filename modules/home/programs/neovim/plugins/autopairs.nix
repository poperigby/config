{ pkgs, ... }:

{
    programs.neovim.plugins = [{
        plugin = pkgs.vimPlugins.nvim-autopairs;
        type = "lua";
        config = # lua
        ''
            require("nvim-autopairs").setup({
                check_ts = true,
                ts_config = {
                    lua = { "string" },
                    -- it will not add pair on that treesitter node
                },
            })
        '';
    }];
}
