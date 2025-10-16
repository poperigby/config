{ pkgs, ... }:

{
  programs.neovim.plugins = with pkgs.vimPlugins; [
    {
      plugin = nvim-notify;
      type = "lua";
      config = # lua
        ''
          require("notify").setup({
            background_colour = "#000000"
          })
          vim.notify = require("notify")
        '';
    }
  ];
}
