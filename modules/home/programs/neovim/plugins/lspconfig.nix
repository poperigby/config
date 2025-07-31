{ pkgs, ... }:

{
  programs.neovim.plugins = with pkgs.vimPlugins; [
    {
      plugin = nvim-lspconfig;
      type = "lua";
      config = # lua
        ''
          -- Change diagnostic symbols in the sign column (gutter)
          vim.diagnostic.config({
              signs = {
                  text = {
                      [vim.diagnostic.severity.ERROR] = " ",
                      [vim.diagnostic.severity.WARN] = " ",
                      [vim.diagnostic.severity.INFO] = "󰋼 ",
                      [vim.diagnostic.severity.HINT] = "󰌵 ",
                  },
              }
          })

          -- Format on save function
          local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
          local format = function(client, bufnr)
              if client:supports_method("textDocument/formatting") then
                  vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
                  vim.api.nvim_create_autocmd("BufWritePre", {
                      group = augroup,
                      buffer = bufnr,
                      callback = function()
                          vim.lsp.buf.format({ bufnr = bufnr })
                      end,
                  })
              end
          end

          local language_servers = {
              csharp_ls = {},
              bashls = {},
              clangd = {
                  cmd = {
                      "clangd",
                      "--background-index",
                      "-j=12",
                      "--clang-tidy",
                      "--clang-tidy-checks=*",
                      "--all-scopes-completion",
                      "--cross-file-rename",
                      "--completion-style=detailed",
                      "--header-insertion-decorators",
                      "--header-insertion=iwyu",
                      "--pch-storage=memory",
                  },
              },
              harper_ls = {},
              jsonls = {},
              lua_ls = {
                  settings = {
                      Lua = {
                          diagnostics = {
                              globals = {
                                  "vim",
                                  "minetest",
                              },
                          },
                      },
                  },
              },
              nixd = {},
              pyright = {},
              rust_analyzer = {
                  settings = {
                      ["rust-analyzer"] = {
                          check = {
                              command = "clippy"
                          }
                      },
                  },
              },
              slint_lsp = {},
              teal_ls = {},
              tinymist = {},
              yamlls = {
                  settings = {
                      yaml = {
                          schemaStore = {
                              -- Must disable built-in schemaStore support to use SchemaStore.nvim
                              -- and its advanced options like `ignore`.
                              enable = false,
                              -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
                              url = "",
                          },
                          schemas = require('schemastore').yaml.schemas(),
                      },
                  },
              },
          }

          for server, config in pairs(language_servers) do
              -- Setup format function
              config.on_attach = format
              -- Setup LSP servers
              vim.lsp.enable(server)
              vim.lsp.config(server, config)
          end
        '';
    }
    SchemaStore-nvim
  ];
}
