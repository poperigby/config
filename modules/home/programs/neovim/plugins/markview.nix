{ pkgs, ... }:

{
    programs.neovim.plugins = [{
        plugin = pkgs.vimPlugins.markview-nvim;
        type = "lua";
        config = # lua
        ''
            require("markview").setup({
                modes = { "i", "n", "no", "c" },
                hybrid_modes = { "i" },

                -- This is nice to have
                callbacks = {
                    on_enable = function(_, win)
                        vim.wo[win].conceallevel = 2;
                        vim.wo[win].conecalcursor = "nc";
                    end
                }
            })
        '';
    }];
}
