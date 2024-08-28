{ pkgs, ... }:

{
    programs.neovim.plugins = [{
        plugin = pkgs.vimPlugins.trouble-nvim;
        type = "lua";
        config = # lua
        ''
            require("trouble").setup({})

            require("which-key").add({
                {
                    "<Leader>r",
                    ":TroubleToggle <CR>",
                    desc = "Toggle trouble",
                },
            })
        '';
    }];
}
