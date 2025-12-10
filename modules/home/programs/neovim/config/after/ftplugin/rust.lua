require("which-key").add({
    {
        "<Space>a",
        function()
            vim.cmd.RustLsp('codeAction') -- Supports rust-analyzer's grouping
            -- or vim.lsp.buf.codeAction() if you don't want grouping.
        end,
    },
    {
        "<Space>h", -- Override Neovim's built-in hover keymap with rustaceanvim's hover actions
        function()
            vim.cmd.RustLsp({ 'hover', 'actions' })
        end,
    }
})
