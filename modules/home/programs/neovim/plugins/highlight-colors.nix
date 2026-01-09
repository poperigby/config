{ pkgs, ... }:

{
    programs.neovim.plugins = [
        {
            plugin = pkgs.vimPlugins.nvim-highlight-colors;
            type = "lua";
            config = # lua
                ''
                    require("nvim-highlight-colors").setup({
                        -- This creates too many false positives
                        enable_short_hex = false
                    })
                '';
        }
    ];
}
