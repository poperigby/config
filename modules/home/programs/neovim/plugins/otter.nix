{ pkgs, ... }:

{
  programs.neovim.plugins = [
    {
      plugin = pkgs.vimPlugins.otter-nvim;
      type = "lua";
      config = # lua
        ''
          require("otter").setup()
        '';
    }
  ];
}
