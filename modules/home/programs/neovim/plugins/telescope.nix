{ pkgs, ... }:

{
    programs.neovim.plugins = with pkgs.vimPlugins; [
        {
            plugin = telescope-nvim;
            type = "lua";
            config = # lua
                ''
                    local telescope = require("telescope")
                    local builtin = require("telescope.builtin")

                    telescope.setup()
                    telescope.load_extension("fzf")
                    telescope.load_extension("ui-select")
                    telescope.load_extension("notify")

                    require("which-key").add({
                        {
                            "<Leader>tt",
                            ":Telescope<CR>",
                            desc = "Launch Telescope"
                        },
                        {
                            "<Leader>tb",
                            builtin.buffers,
                            desc = "Explore buffers"
                        },
                        {
                            "<Leader>td",
                            builtin.diagnostics,
                            desc = "Explore diagnostics"
                        },
                        {
                            "<Leader>tg",
                            builtin.live_grep,
                            desc = "Search in files"
                        },
                        {
                            "<Leader>to",
                            builtin.oldfiles,
                            desc = "Explore previously opened files"
                        },
                        {
                            "<Leader>tn",
                            telescope.extensions.notify.notify,
                            desc = "Explore notification history"
                        },
                    })
                '';
        }

        nvim-web-devicons
        popup-nvim
        telescope-fzf-native-nvim
        telescope-ui-select-nvim
    ];
}
