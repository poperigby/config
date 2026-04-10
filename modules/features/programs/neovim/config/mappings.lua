local map = vim.keymap.set

-- Yank to system regular clipboard
map("v", "<C-c>", '"+y', { desc = "Yank to system clipboard" })
map("v", "<C-a>", '"+yG', { desc = "Yank file contents to system clipboard" })

-- Quick buffer switching
map("n", "<Leader><Tab>", ":bn<CR>", { desc = "Move to next buffer" })
map("n", "<Leader><S-Tab>", ":bp<CR>", { desc = "Move to previous buffer" })

-- Yank to the end of line
map("n", "Y", "y$", { desc = "Yank to the end of the line" })

-- LSP
map("n", "<Space>;", function() vim.diagnostic.jump({ count = 1 }) end, { desc = "Move to next diagnostic" })
map("n", "<Space>,", function() vim.diagnostic.jump({ count = -1 }) end, { desc = "Move to previous diagnostic" })
map("n", "<Space>a", vim.lsp.buf.code_action, { desc = "Open a code action menu" })
map("n", "<Space>d", vim.lsp.buf.definition, { desc = "Jump to the definition of the symbol" })
map("n", "<Space>r", vim.lsp.buf.rename, { desc = "Rename all references to the symbol" })
map("n", "<Space>m", vim.lsp.buf.references, { desc = "List all the references to the symbol" })
map("n", "<Space>h", vim.lsp.buf.hover, { desc = "Show hover information about the symbol" })
