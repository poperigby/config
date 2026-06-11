-- Set file types

local autocmd = vim.api.nvim_create_autocmd

local function set_filetype(extension, filetype)
    autocmd({ "BufRead", "BufNewFile" }, {
        pattern = "*." .. extension,
        callback = function()
            vim.bo.filetype = filetype
        end,
    })
end

set_filetype("pmodule", "python")
set_filetype("pybuild", "python")
set_filetype("settings", "dosini")

-- Use YAML filetype for clang files (enable nice syntax highlighting)
autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "dot_clang-format", ".clang-format", "dot_clang-tidy", ".clang-tidy" },
    callback = function()
        vim.bo.filetype = "yaml"
    end,
})

-- Set up optimal settings for writing prose
autocmd("FileType", {
    pattern = "markdown",
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
        vim.opt_local.spell = true
        vim.opt_local.conceallevel = 2
    end,
})

-- Set the correct filetype for Justfiles
autocmd({ "BufRead", "BufNewFile" }, {
    pattern = "Justfile",
    callback = function()
        vim.bo.filetype = "just"
    end,
})
