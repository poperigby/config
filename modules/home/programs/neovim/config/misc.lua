local autocmd = vim.api.nvim_create_autocmd

-- Misc auto commands
autocmd({ "TextYankPost" }, { -- Highlight text briefly after yank
    pattern = "*",
    callback = function()
        vim.highlight.on_yank({ on_visual = false })
    end,
})

-- Disable TreeSitter if file is >1MB
autocmd("BufReadPost", {
    pattern = { "*" },
    callback = function()
        local filesize = vim.fn.getfsize(vim.fn.expand("%:p"))
        if filesize < 1024 * 1024 then
            vim.treesitter.stop()
        end
    end,
})

-- Disable built-in plugins
local disabled_built_ins = {
    "gzip",
    "zip",
    "zipPlugin",
    "tar",
    "tarPlugin",
    "getscript",
    "getscriptPlugin",
    "vimball",
    "vimballPlugin",
    "2html_plugin",
    "logipat",
    "rrhelper",
    "spellfile_plugin",
    "matchit",
}

for _, plugin in pairs(disabled_built_ins) do
    vim.g["loaded_" .. plugin] = 1
end
