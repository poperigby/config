{
    config,
    lib,
    pkgs,
    ...
}:

let
    # Firefox profile and Wayland app-id for the standalone preview window
    name = "livepreview";

    # The bundled highlight.js build only includes the common languages
    nixGrammar = pkgs.fetchurl {
        url = "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.11.1/languages/nix.min.js";
        sha256 = "1whb4pqv2fb1sasafv5i15626nlg4z43mbl0l21l7agwpav6d1wg";
    };
in
{
    programs.neovim.plugins = [
        {
            plugin = pkgs.vimPlugins.live-preview-nvim.overrideAttrs (old: {
                postPatch = (old.postPatch or "") + ''
                    cat ${nixGrammar} >> static/highlight/highlight.min.js
                '';
            });
            type = "lua";
            config = # lua
                ''
                    local livepreview = require("livepreview")
                    local lpconfig = require("livepreview.config")

                    lpconfig.set({
                        sync_scroll = true,
                        -- Serve from the previewed file's directory so files outside
                        -- the working directory can be previewed
                        dynamic_root = true,
                    })
                    local config = lpconfig.config

                    local function niri(...)
                        if vim.env.NIRI_SOCKET then
                            return vim.system({ "niri", "msg", ... }, { text = true }):wait()
                        end
                    end

                    -- The editor's window is halved while the preview is open and
                    -- restored to full width afterwards
                    local editor_window = nil

                    local function shrink_editor()
                        if editor_window then
                            return
                        end
                        local focused = niri("--json", "focused-window")
                        if not focused or focused.code ~= 0 then
                            return
                        end
                        local ok, window = pcall(vim.json.decode, focused.stdout)
                        if ok and type(window) == "table" then
                            editor_window = window.id
                            niri("action", "set-window-width", "--id", tostring(editor_window), "50%")
                        end
                    end

                    local function restore_editor()
                        if editor_window then
                            niri("action", "set-window-width", "--id", tostring(editor_window), "100%")
                            editor_window = nil
                        end
                    end

                    -- Stop the server without the plugin's "Server closed" message
                    livepreview.close = function()
                        if livepreview.serverObj then
                            livepreview.serverObj:stop()
                            livepreview.serverObj = nil
                        end
                    end

                    -- The preview opens in its own Firefox instance and profile so it
                    -- stays separate from the main browser session
                    local browser = nil
                    local previewed = nil
                    local enabled = true

                    local function kill_browser()
                        if browser then
                            local handle = browser
                            browser = nil
                            handle:kill("sigterm")
                        end
                    end

                    local function stop()
                        livepreview.close()
                        previewed = nil
                        kill_browser()
                        restore_editor()
                    end

                    local function open_browser(url)
                        shrink_editor()
                        local handle
                        handle = vim.system({
                            "firefox",
                            "--new-instance",
                            "-P", "${name}",
                            "--name", "${name}",
                            url,
                        }, {}, function()
                            -- Closing the preview window by hand stops the preview
                            vim.schedule(function()
                                if browser == handle then
                                    browser = nil
                                    stop()
                                end
                            end)
                        end)
                        browser = handle
                    end

                    local function start(path)
                        if previewed == path then
                            return
                        end
                        kill_browser()
                        if not livepreview.start(path, config.port) then
                            return
                        end
                        previewed = path
                        open_browser(("http://%s:%d/%s"):format(
                            config.address,
                            config.port,
                            vim.uri_encode(vim.fs.basename(path))
                        ))
                    end

                    local function preview_buffer(buf)
                        if not enabled or vim.bo[buf].filetype ~= "markdown" or vim.bo[buf].buftype ~= "" then
                            return
                        end
                        local path = vim.api.nvim_buf_get_name(buf)
                        if path ~= "" then
                            start(vim.fs.normalize(path))
                        end
                    end

                    local group = vim.api.nvim_create_augroup("LivePreviewAuto", {})

                    -- Preview Markdown buffers automatically in graphical sessions
                    if vim.env.WAYLAND_DISPLAY then
                        vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
                            group = group,
                            callback = function(args)
                                preview_buffer(args.buf)
                            end,
                        })
                    end

                    vim.api.nvim_create_autocmd("BufDelete", {
                        group = group,
                        callback = function(args)
                            local path = vim.api.nvim_buf_get_name(args.buf)
                            if previewed and path ~= "" and vim.fs.normalize(path) == previewed then
                                stop()
                            end
                        end,
                    })

                    vim.api.nvim_create_autocmd("VimLeavePre", {
                        group = group,
                        callback = stop,
                    })

                    require("which-key").add({
                        "<Leader>m",
                        function()
                            enabled = not enabled
                            if enabled then
                                preview_buffer(0)
                            else
                                stop()
                            end
                        end,
                        desc = "Toggle Markdown live preview"
                    })
                '';
        }
    ];

    programs.firefox.profiles.${name} = lib.mkIf config.programs.firefox.enable {
        id = 1;
        # Show only the page content
        userChrome = # css
            ''
                #TabsToolbar,
                #nav-bar,
                #PersonalToolbar,
                #sidebar-header {
                    visibility: collapse !important;
                }
            '';
        settings = {
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
            # The plugin derives ETags from file mtimes, which are constant in the
            # Nix store, so cached assets would survive plugin updates
            "browser.cache.disk.enable" = false;
            "browser.aboutwelcome.enabled" = false;
            "browser.shell.checkDefaultBrowser" = false;
            "browser.startup.homepage_override.mstone" = "ignore";
            "browser.sessionstore.resume_from_crash" = false;
            "browser.tabs.warnOnClose" = false;
            "datareporting.policy.dataSubmissionEnabled" = false;
            "datareporting.healthreport.uploadEnabled" = false;
            "toolkit.telemetry.reportingpolicy.firstRun" = false;
        };
    };

    # Open the preview unfocused at half width in a column beside the editor
    # and keep it opaque. Placed last so it overrides the general rules.
    wayland.windowManager.niri.settings._children = lib.mkIf config.wayland.windowManager.niri.enable (
        lib.mkAfter [
            {
                window-rule._children = [
                    { match._props.app-id = "^${name}$"; }
                    { default-column-width._children = [ { proportion = 0.5; } ]; }
                    { opacity = 1.0; }
                    { open-focused = false; }
                ];
            }
        ]
    );
}
