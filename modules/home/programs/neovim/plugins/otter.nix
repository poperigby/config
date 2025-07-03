{ pkgs, ... }:

{
  programs.neovim.plugins = [
    {
      plugin = pkgs.vimPlugins.otter-nvim;
      type = "lua";
      config = # lua
        ''
          require("otter").setup()

          -- This code will run whenever you enter insert mode...
          vim.api.nvim_create_autocmd("InsertEnter", {
              group = vim.api.nvim_create_augroup("otter-autostart", {}),
              -- ...But this only runs in markdown and Nix files
              pattern = { "*.md", "*.nix" },
              callback = function()
                  -- Get the treesitter parser for the current buffer
                  local ok, parser = pcall(vim.treesitter.get_parser)
                  if not ok then return end

                  local otter      = require("otter")
                  local extensions = require("otter.tools.extensions")
                  local attached   = {}

                  -- Get the language for the current cursor position (this will be
                  -- determined by the current code chunk if that's where the cursor
                  -- is)
                  local line, col = vim.fn.line(".") - 1, vim.fn.col(".")
                  local lang = parser:language_for_range({ line, col, line, col + 1 }):lang()

                  -- If otter has an extension available for that language, and if
                  -- the LSP isn't already attached, then activate otter for that
                  -- language
                  if extensions[lang] and not vim.tbl_contains(attached, lang) then
                      table.insert(attached, lang)
                      vim.schedule(function() otter.activate({ lang }, true, true) end)
                  end
              end
          })
        '';
    }
  ];
}
