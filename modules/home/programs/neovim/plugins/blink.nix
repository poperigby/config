{ pkgs, ... }:

{
    programs.neovim.plugins = [
        {
            plugin = pkgs.vimPlugins.blink-cmp;
            type = "lua";
            config = # lua
                ''
                    require("blink-cmp").setup({
                        keymap = {
                            preset = "enter",
                            ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
                            ["<S-Tab>"] = { "select_prev", "snippet_forward", "fallback" },
                        },
                        appearance = {
                            -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
                            -- Adjusts spacing to ensure icons are aligned
                            nerd_font_variant = "mono"
                        },
                        -- default list of enabled providers defined so that you can extend it
                        -- elsewhere in your config, without redefining it, via `opts_extend`
                        sources = {
                            default = { "lsp", "path", "snippets", "buffer" },
                        },
                        completion = {
                            list = {
                                selection = {
                                    -- Don't automatically show completion menu in cmdline
                                    auto_insert = false
                                },
                            },
                            documentation = {
                                auto_show = true,
                                auto_show_delay_ms = 10,
                            },
                        }
                    })
                '';
        }
    ];
}
