{ pkgs, ... }:

{
  programs.neovim.plugins = [
    {
      plugin = pkgs.vimPlugins.hardtime-nvim;
      type = "lua";
      config = # lua
        ''
          require("hardtime").setup()
        '';
    }
  ];
}
