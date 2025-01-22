{ pkgs, ... }:

{
  programs.neovim.plugins = [
    {
      plugin = pkgs.vimPlugins.yazi-nvim;
      type = "lua";
      config = # lua
        ''
          require("which-key").add({
              {
                  "<Leader>e",
                  function() require("yazi").yazi() end,
                  desc = "Explore files in Yazi",
              },
          })
        '';
    }
  ];
}
