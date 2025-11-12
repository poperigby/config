{ pkgs, ... }:

{
    programs.neovim.plugins = with pkgs.vimPlugins; [
        {
            plugin = telescope-nvim;
            type = "lua";
            config = ''
                require("telescope").setup()
                require("telescope").load_extension("fzf")
                require("telescope").load_extension("ui-select")

                local builtin = require("telescope.builtin")
                require("which-key").add({
                    {
                        "<Leader>fb",
                        builtin.buffers,
                        desc = "Explore buffers",
                    },
                    {
                        "<Leader>fd",
                        builtin.diagnostics,
                        desc = "Explore diagnostics",
                    },
                    {
                        "<Leader>fg",
                        builtin.live_grep,
                        desc = "Search in files",
                    },
                    {
                        "<Leader>fo",
                        builtin.oldfiles,
                        desc = "Explore previously opened files",
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
