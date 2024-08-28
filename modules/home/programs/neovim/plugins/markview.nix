{ pkgs, ... }:

{
    programs.neovim.plugins = with pkgs.vimPlugins; [
        {
            plugin = markview-nvim;
            type = "lua";
            config = # lua
            ''
                require("markview").setup({
                    modes = { "n", "i", "no", "c" },
                    hybrid_modes = { "i", "n" },

                    -- This is nice to have
                    callbacks = {
                        on_enable = function(_, win)
                            vim.wo[win].conceallevel = 2;
                            vim.wo[win].conecalcursor = "nc";
                        end
                    }
                })
            '';
        }
        nvim-web-devicons
    ];
}
