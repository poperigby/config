{ pkgs, ... }:

{
  programs.neovim.plugins = [
    {
      plugin = pkgs.vimPlugins.blink-cmp.overrideAttrs (old: {
        patches = [
          (pkgs.replaceVars (pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/HeitorAugustoLN/nixpkgs/8fd65e57f1d1fdbe5151d23a972b00c632d33162/pkgs/applications/editors/vim/plugins/non-generated/blink-cmp/force-version.patch";
            hash = "sha256-/3psGDvmZBg7fXNJNtErV2dqzRqsMdAc1d6vaMpxdN0=";
          }) { inherit (old.src) tag; })
        ];
      });
      type = "lua";
      config = # lua
        ''
          require("blink-cmp").setup({
              keymap = {
                  preset = "enter",
                  ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
                  ["<S-Tab>"] = { "select_prev", "snippet_forward", "fallback" },
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
                  cmdline = {
                      min_keyword_length = 2,
                  },
              },

              -- Don't automatically show completion menu in cmdline
              completion = {
                  list = {
                      selection = 'auto_insert',
                  },
              }
          })
        '';
    }
  ];
}
