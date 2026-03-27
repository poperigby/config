{ pkgs, ... }:

{
    programs.neovim.plugins = [
        {
            plugin = pkgs.vimPlugins.hex-nvim;
            type = "lua";
            config = # lua
                ''
                    require("hex").setup({})
                '';
        }
    ];

    home.packages = [ pkgs.tinyxxd ];
}
