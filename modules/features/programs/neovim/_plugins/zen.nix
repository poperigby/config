{ pkgs, ... }:

{
    programs.neovim.plugins = with pkgs.vimPlugins; [
        {
            plugin = zen-mode-nvim;
            type = "lua";
            config = # lua
                ''
                    -- Set up optimal settings for writing prose
                    vim.api.nvim_create_autocmd({ "VimEnter", "BufReadPost" }, {
                        pattern = { "*.md", "*.txt", },
                        callback = function()
                            vim.opt_local.wrap = true
                            vim.opt_local.linebreak = true
                            vim.opt_local.spell = true
                            vim.opt_local.conceallevel = 2

                            require("zen-mode").open()
                        end,
                    })
                '';
        }
        twilight-nvim
    ];
}
