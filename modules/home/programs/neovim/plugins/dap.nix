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

                    -- Cargo helper for Rust
                    local CargoExecTypes = {
                        TEST = "cargo build --tests -q --message-format=json",
                        BIN = "cargo build -q --message-format=json"
                    }
                    local function runCargoBuild(type)
                        local lines = vim.fn.systemlist(type)
                        local output = table.concat(lines, "\n")
                        local filename = output:match('^.*"executable":"(.*)",.*\n.*,"success":true}$')

                        if filename == nil then
                            return error("failed to build cargo project")
                        end

                        return filename
                    end

                    dap.adapters = {
                        codelldb = {
                            executable = "${codelldb}",
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
                                name = "Debug main binary",
                                type = "codelldb",
                                request = "launch",
                                program = function()
                                    return runCargoBuild(CargoExecTypes.BIN)
                                end,
                                cwd = "''${workspaceFolder}",
                                stopOnEntry = false,
                            },
                            {
                                name = "Debug test binary",
                                type = "codelldb",
                                request = "launch",
                                program = function()
                                    return runCargoBuild(CargoExecTypes.TEST)
                                end,
                                cwd = "''${workspaceFolder}",
                                stopOnEntry = false,
                            },
                        },
                        cs = {{
                            name = "Launch file",
                            type = "coreclr",
                            request = "launch",
                            program = function()
                                return vim.fn.input("Path to dll", vim.fn.getcwd() .. "/bin/Debug/", "file")
                            end,
                        }},
                    }

                    -- Dap-view and virtual text
                    require("dap-view").setup({
                        auto_toggle = true,
                        follow_tab = true,
                    })
                    require("nvim-dap-virtual-text").setup()

                    -- Breakpoint signs
                    vim.fn.sign_define("DapBreakpoint", {
                        text = " ",
                        texthl = "DiagnosticError",
                        linehl = "",
                        numhl = "",
                    })
                    vim.fn.sign_define("DapBreakpointCondition", {
                        text = " ",
                        texthl = "DiagnosticWarn",
                    })
                    vim.fn.sign_define("DapBreakpointRejected", {
                        text = " ",
                        texthl = "DiagnosticError",
                    })
                    vim.fn.sign_define("DapStopped", {
                        text = "󰁕 ",
                        texthl = "DiagnosticInfo",
                    })

                    -- Keybindings
                    require("which-key").add({
                        {
                            "<Leader>db",
                            dap.toggle_breakpoint,
                            desc = "Toggle breakpoint"
                        },
                        {
                            "<Up>",
                            dap.restart_frame,
                            desc = "Restart debugging frame"
                        },
                        {
                            "<Down>",
                            dap.step_over,
                            desc = "Step over debugging frame"
                        },
                        {
                            "<Left>",
                            dap.step_out,
                            desc = "Step out of debugging frame"
                        },
                        {
                            "<Right>",
                            dap.step_into,
                            desc = "Step into debugging frame"
                        }
                    })
                '';
        }

        nvim-dap-view
        nvim-dap-virtual-text
    ];
}
