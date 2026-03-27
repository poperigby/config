{ pkgs, ... }:

{
    programs.neovim.plugins = [
        {
            plugin = pkgs.vimPlugins.fidget-nvim;
            type = "lua";
            config = # lua
                ''
                    require("fidget").setup({
                        progress = {
                            display = {
                                done_icon = ""
                            }
                        },
                        notification = {
                            window = {
                                winblend = 0
                            },
                        },
                    })
                '';
        }
    ];
}
