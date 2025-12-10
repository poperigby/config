{ pkgs, ... }:

{
    programs.neovim.plugins = [
        {
            plugin = pkgs.vimPlugins.rustaceanvim;
            type = "lua";
        }
    ];
}
