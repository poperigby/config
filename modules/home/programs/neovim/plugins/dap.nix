{ lib, pkgs, ... }:

{
    programs.neovim.plugins = [{
        plugin = pkgs.vimPlugins.nvim-dap;
        type = "lua";
        config = # lua
        ''
            local dap = require("dap")

            dap.adapters = {
                coreclr = {
                    type = "executable",
                    command = "${lib.getExe pkgs.netcoredbg}",
                    args = { "--interpreter=vscode" }
                }
            }

            dap.configurations = {
                cs = {{
                        type = "coreclr",
                        name = "launch - netcoredbg",
                        request = "launch",
                        program = function()
                            return vim.fn.input("Path to dll", vim.fn.getcwd() .. "/bin/Debug/", "file")
                        end,
                }},
            }
        '';
    }];
}
