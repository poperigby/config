{ pkgs, ... }:

{
    programs.neovim.plugins = [{
        plugin = pkgs.vimPlugins.nvim-lspconfig;
        type = "lua";
        config = # lua
        ''
            -- Change diagnostic symbols in the sign column (gutter)
            local signs = { Error = "󰅚 ", Warn = "󰀪 ", Hint = "󰌶 ", Info = " " }
            for type, icon in pairs(signs) do
                local hl = "DiagnosticSign" .. type
                vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
            end

            -- Format on save function
            local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
            local format = function(client, bufnr)
                if client.supports_method("textDocument/formatting") then
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
                ruff = {},
                rust_analyzer = {
                    settings = {
                        ["rust-analyzer"] = {
                            checkOnSave = {
                                command = "clippy"
                            }
                        },
                    },
                }
            }

            for server, config in pairs(language_servers) do
                -- Setup format function
                config.on_attach = format
                -- Setup LSP servers
                require("lspconfig")[server].setup(config)
            end
        '';
    }];
}
