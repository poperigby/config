return {
    "ellisonleao/gruvbox.nvim",
    config = function()
        vim.o.background = "dark"

        require("gruvbox").setup({
            transparent_mode = true,
            italic = {
                strings = false
            },
            overrides = {
                -- Make incorrectly spelled words have a curly red underline
                SpellBad                 = { undercurl = true, sp = "#fb4934" },

                -- Use straight underlines for diagnostics
                DiagnosticUnderlineError = { underline = true, sp = "#fb4934" },
                DiagnosticUnderlineWarn  = { underline = true, sp = "#fabd2f" },
                DiagnosticUnderlineInfo  = { underline = true, sp = "#83a598" },
                DiagnosticUnderlineHint  = { underline = true, sp = "#8ec07c" },

                -- Make float backgrounds darker (and not transparent)
                NormalFloat              = { bg = "#282828" },

                -- Make nixd module options blue
                ["@lsp.type.method.nix"] = { fg = "#83a598" },
            },
        })

        vim.cmd("colorscheme gruvbox")
    end,
    priority = 1000,
}
