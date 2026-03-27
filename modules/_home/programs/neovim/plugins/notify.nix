{ pkgs, ... }:

{
    programs.neovim.plugins = [
        {
            plugin = pkgs.vimPlugins.nvim-notify;
            type = "lua";
            config = # lua
                ''
                    local notify = require("notify")

                    notify.setup({
                        background_colour = "#000000",
                    })

                    vim.notify = notify
                '';
        }
    ];
}
