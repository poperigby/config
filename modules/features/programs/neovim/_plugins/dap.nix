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
                        -- Only build the crate containing the current buffer, so a
                        -- workspace yields that crate's executable rather than whichever
                        -- member cargo happens to report first
                        local crate_root = vim.fs.root(0, "Cargo.toml")
                        if crate_root ~= nil then
                            type = type .. " --manifest-path " .. vim.fn.shellescape(crate_root .. "/Cargo.toml")
                        end

                        local lines = vim.fn.systemlist(type)
                        local output = table.concat(lines, "\n")

                        local filename = output:match('"executable":"(.-)"')

                        if filename == nil then
                            vim.notify("Cargo build failed:\n" .. output, vim.log.levels.ERROR)
                            error("Cargo build failed, see message above")
                        end

                        return filename
                    end

                    dap.adapters = {
                        codelldb = {
                            type = "executable",
                            command = "${codelldb}",
                        },
                        coreclr = {
                            type = "executable",
                            command = "${getExe pkgs.netcoredbg}",
                            args = { "--interpreter=vscode" }
                        },
                        delve = {
                            type = "server",
                            port = "''${port}",
                            executable = {
                                command = "${getExe pkgs.delve}",
                                args = { "dap", "-l", "127.0.0.1:''${port}" },
                            }
                        }
                    }

                    -- Break on panics, otherwise libtest swallows them and the session just ends
                    dap.defaults.codelldb.exception_breakpoints = { "rust_panic" }

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
                        go = {
                            {
                                name = "Debug package",
                                type = "delve",
                                request = "launch",
                                program = "''${fileDirname}",
                            },
                            {
                                name = "Debug file",
                                type = "delve",
                                request = "launch",
                                program = "''${file}",
                            },
                            {
                                name = "Debug package tests",
                                type = "delve",
                                request = "launch",
                                mode = "test",
                                program = "''${fileDirname}",
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
