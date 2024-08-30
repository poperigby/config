{ pkgs, ... }:

{
    programs.neovim.plugins = [{
        plugin = pkgs.vimPlugins.img-clip-nvim;
        type = "lua";
        config = # lua
        ''
            require("which-key").add({
                "<Leader>p",
                "<cmd>PasteImage<cr>",
                desc = "Paste image from the sytem clipboard"
            })
        '';
    }];
}
