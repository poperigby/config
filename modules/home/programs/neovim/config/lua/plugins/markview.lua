return {
    "OXY2DEV/markview.nvim",
    lazy = false,
    submodules = false,
    dependencies = {
        -- Used by the code blocks
        "nvim-tree/nvim-web-devicons",
    },
    opts = {
        modes = { "n", "i", "no", "c" },
        hybrid_modes = { "i", "n" },

        -- This is nice to have
        callbacks = {
            on_enable = function(_, win)
                vim.wo[win].conceallevel = 2;
                vim.wo[win].conecalcursor = "nc";
            end
        }
    },
};
