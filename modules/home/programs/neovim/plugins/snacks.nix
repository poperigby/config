{ pkgs, ... }:

{
  programs.neovim.plugins = [
    {
      plugin = pkgs.vimPlugins.snacks-nvim;
      type = "lua";
      config = # lua
        ''
          require("snacks").setup({
              bigfile = { enabled = true },
              input = { enabled = true },
              notifier = {
                  enabled = true,
                  style = "fancy",
              },
              scratch = { enabled = true },
          })

          require("which-key").add({
              "<Leader>.",
              function() require("snacks").scratch() end,
              desc = "Toggle scratch buffer"
          })
        '';
    }
  ];
}
