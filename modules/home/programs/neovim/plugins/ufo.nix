{ pkgs, ... }:

{
    programs.neovim.plugins = [
        {
            plugin = pkgs.vimPlugins.nvim-ufo;
            type = "lua";
            config = # lua
                ''
                    require("ufo").setup({
                        provider_selector = function()
                            return { "treesitter", "indent" }
                        end,
                    })

                    require("which-key").add({
                        {
                            "zR",
                            function()
                                require("ufo").openAllFolds()
                            end,
                        },
                        {
                            "zM",
                            function()
                                require("ufo").closeAllFolds()
                            end,
                        },
                        {
                            "<Space>h",
                            function()
                                local winid = require("ufo").peekFoldedLinesUnderCursor()
                                if not winid then
                                    vim.lsp.buf.hover()
                                end
                            end,
                        },
                    })

                    vim.opt.foldcolumn = "0"
                    vim.opt.foldlevel = 99
                    vim.opt.foldlevelstart = 99
                    vim.opt.foldenable = true
                    vim.opt.conceallevel = 2
                '';
        }
    ];
}
