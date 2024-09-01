{ pkgs, ... }:

{
    programs.neovim.plugins = with pkgs.vimPlugins; [
        {
            plugin = telescope-nvim;
            type = "lua";
            config = # lua
            ''
                require("telescope").setup()
                require("telescope").load_extension("fzf")

                local builtin = require("telescope.builtin")
                require("which-key").add({
                    {
                        "<Leader>fb",
                        builtin.buffers,
                        desc = "Explore buffers",
                    },
                    {
                        "<Leader>fg",
                        builtin.live_grep,
                        desc = "Search in files",
                    },
                })
            '';
        }
        nvim-web-devicons
        popup-nvim
        telescope-fzf-native-nvim
    ];
}
