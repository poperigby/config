{ lib, pkgs, ... }:

{
    programs.neovim.plugins = with pkgs.vimPlugins; [
        {
            plugin = nvim-dap;
            type = "lua";
            config =
                let
                    inherit (lib) getExe;

                    codelldb = "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb";
                in
                # lua
                ''
                    local dap = require("dap")

                    dap.adapters = {
                        codelldb = {
                            type = "executable",
                            command = "${codelldb}",
                        },
                        coreclr = {
                            type = "executable",
                            command = "${getExe pkgs.netcoredbg}",
                            args = { "--interpreter=vscode" }
                        }
                    }

                    dap.configurations = {
                        rust = {
                            {
                                name = "Launch file",
                                type = "codelldb",
                                request = "launch",
                                program = function()
                                    return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                                end,
                                cwd = "''${workspaceFolder}",
                                stopOnEntry = false,
                            },
                        },
                        cs = {{
                            name = "launch - netcoredbg",
                            type = "coreclr",
                            request = "launch",
                            program = function()
                                return vim.fn.input("Path to dll", vim.fn.getcwd() .. "/bin/Debug/", "file")
                            end,
                        }},
                    }
                '';
        }

        nvim-dap-view
    ];
}
