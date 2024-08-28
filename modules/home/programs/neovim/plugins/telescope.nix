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

                require("which-key").add({
                    {
                        "<Leader>t",
                        ":Telescope <CR>",
                        desc = "Opens Telescope",
                    },
                    {
                        "<Leader>e",
                        ":Telescope find_files <CR>",
                        desc = "Explore files in Telescope",
                    },
                    {
                        "<Leader>b",
                        ":Telescope buffers <CR>",
                        desc = "Explore buffers in Telescope",
                    },
                    {
                        "<Leader>f",
                        ":Telescope live_grep <CR>",
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
