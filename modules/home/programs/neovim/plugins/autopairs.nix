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
                    -- Don't automatically create pairs in strings
                    lua = { "string" },
                },
            })
        '';
    }];
}
