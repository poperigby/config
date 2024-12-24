local options = {
    transparency = 0.9,
    -- Disable cursor animation
    cursor_animation_length = 0,
}

for k, v in pairs(options) do
    vim.g["neovide_" .. k] = v
end

