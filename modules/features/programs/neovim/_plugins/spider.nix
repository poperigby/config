{ pkgs, ... }:

{
    programs.neovim.plugins = [
        {
            plugin = pkgs.vimPlugins.nvim-spider;
            type = "lua";
            config = # lua
                ''
                    local spider = require("spider") 

                    require("which-key").add({
                        {
                            ",w",
                            function() spider.motion("w") end,
                            desc = "Next subword",
                            mode = {"n", "o", "x"}
                        },
                        {
                            ",b",
                            function() spider.motion("b") end,
                            desc = "Prev subword",
                            mode = {"n", "o", "x"}
                        },
                        {
                            ",e",
                            function() spider.motion("e") end,
                            desc = "Next end of subword",
                            mode = {"n", "o", "x"}
                        },
                        {
                            ",ge",
                            function() spider.motion("ge") end,
                            desc = "Prev end of subword",
                            mode = {"n", "o", "x"}
                        },
                    })
                '';
        }
    ];
}
