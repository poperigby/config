{ pkgs, ... }:

{
    programs.neovim.plugins = [
        {
            plugin = pkgs.vimPlugins.nvim-highlight-colors;
            type = "lua";
            config = ''
                require("nvim-highlight-colors").setup({
                    -- This creates too many false positives
                    enable_short_hex = false,
                    exclude_filetypes = { "xxd" },
                })
            '';
        }
    ];
}
