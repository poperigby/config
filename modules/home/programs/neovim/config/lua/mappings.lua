require("which-key").add({
    {
        "<C-c>",
        '"+y',
        desc = "Yank to system clipboard",
        mode = "v"
    },
    {
        "<C-a>",
        '%y+',
        desc = "Yank file contents to system clipboard"
    },
    {
        "Y",
        "y$",
        desc = "Yank to the end of the line"
    },

    -- LSP
    {
        "<Space>;",
        function() vim.diagnostic.jump({ count = 1 }) end,
        desc = "Move to next diagnostic"
    },
    {
        "<Space>,",
        function() vim.diagnostic.jump({ count = -1 }) end,
        desc = "Move to previous diagnostic"
    },
    {
        "<Space>a",
        vim.lsp.buf.code_action,
        desc = "Open a code action menu"
    },
    {
        "<Space>d",
        vim.lsp.buf.definition,
        desc = "Jump to the definition of the symbol"
    },
    {
        "<Space>r",
        vim.lsp.buf.rename,
        desc = "Rename all references to the symbol"
    },
    {
        "<Space>m",
        vim.lsp.buf.references,
        desc = "List all the references to the symbol"
    },
    {
        "<Space>h",
        vim.lsp.buf.hover,
        desc = "Show hover information about the symbol"
    },
})
