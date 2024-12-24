if vim.g.neovide then
    local options = {
        transparency = 0.9,
        -- Disable cursor animation
        cursor_animation_length = 0,
    }

    require("gruvbox").setup({
        overrides = { Normal = { bg = "#32302f" } }
    })

    for k, v in pairs(options) do
        vim.g["neovide_" .. k] = v
    end
end
