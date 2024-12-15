{ pkgs, ... }:

{
  programs.neovim.plugins = [
    {
      plugin = pkgs.vimPlugins.blink-cmp;
      type = "lua";
      config = # lua
        ''
          require("blink-cmp").setup({
              keymap = {
                  preset = "enter",
                  ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
                  ["<S-Tab>"] = { "select_prev", "snippet_forwad", "fallback" },
              },

              appearance = {
                  -- Sets the fallback highlight groups to nvim-cmp's highlight groups
                  -- Useful for when your theme doesn't support blink.cmp
                  -- will be removed in a future release
                  use_nvim_cmp_as_default = true,
                  -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
                  -- Adjusts spacing to ensure icons are aligned
                  nerd_font_variant = "mono"
              },

              -- default list of enabled providers defined so that you can extend it
              -- elsewhere in your config, without redefining it, via `opts_extend`
              sources = {
                  default = { "lsp", "path", "snippets", "buffer" },
              },
          })
        '';
    }
  ];
}
