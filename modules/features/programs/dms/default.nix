{ ... }:
{
    den.aspects.programs.provides.dms =
        {
            settings ? { },
            pluginSettings ? { },
        }:
        {
            nixos =
                { pkgs, ... }:
                {
                    programs.dms-shell = {
                        enable = true;

                        systemd = {
                            enable = true;
                            restartIfChanged = true;
                        };

                        plugins = {
                            calculator.src = pkgs.applyPatches {
                                src = pkgs.fetchFromGitHub {
                                    owner = "poperigby";
                                    repo = "DankCalculator";
                                    rev = "numbat-debounce";
                                    hash = "sha256-K/24VCf+IzNyck50Aco6kJfBE4Lji3ue3UCd5dBBRc8=";
                                };
                            };
                            emoji-unicode-picker.src = pkgs.fetchFromGitHub {
                                owner = "devnullvoid";
                                repo = "dms-emoji-launcher";
                                rev = "main";
                                hash = "sha256-fmIddCvACwO8wbAtLBMtDnEXXQJjb7+o2s4jW3f8VIU=";
                            };
                        };

                        enableSystemMonitoring = true;
                        enableVPN = true;
                        enableDynamicTheming = true;
                        enableAudioWavelength = true;
                        enableCalendarEvents = true;
                        enableClipboardPaste = true;
                    };

                    programs.dsearch.enable = true;

                    services.displayManager.dms-greeter = {
                        enable = true;
                        compositor.name = "niri";
                        configHome = "/home/cassidy";
                    };
                };

            homeManager =
                { pkgs, ... }:
                let
                    jsonFormat = pkgs.formats.json { };
                    commonSettings = builtins.fromJSON (builtins.readFile ./settings.json);
                    commonPluginSettings = builtins.fromJSON (builtins.readFile ./plugin_settings.json);
                in
                {
                    wayland.windowManager.niri.settings = {
                        binds = {
                            "Mod+Space" = {
                                _props.hotkey-overlay-title = "Open the application launcher";
                                spawn = [
                                    "dms"
                                    "ipc"
                                    "spotlight"
                                    "toggle"
                                ];
                            };
                            "Mod+N" = {
                                _props.hotkey-overlay-title = "Notification Center";
                                spawn = [
                                    "dms"
                                    "ipc"
                                    "call"
                                    "notifications"
                                    "toggle"
                                ];
                            };
                            "Mod+V" = {
                                _props.hotkey-overlay-title = "Clipboard Manager";
                                spawn = [
                                    "dms"
                                    "ipc"
                                    "call"
                                    "clipboard"
                                    "toggle"
                                ];
                            };

                            "XF86AudioRaiseVolume" = {
                                _props.allow-when-locked = true;
                                spawn = [
                                    "dms"
                                    "ipc"
                                    "call"
                                    "audio"
                                    "increment"
                                    "3"
                                ];
                            };
                            "XF86AudioLowerVolume" = {
                                _props.allow-when-locked = true;
                                spawn = [
                                    "dms"
                                    "ipc"
                                    "call"
                                    "audio"
                                    "decrement"
                                    "3"
                                ];
                            };
                            "XF86AudioMute" = {
                                _props.allow-when-locked = true;
                                spawn = [
                                    "dms"
                                    "ipc"
                                    "call"
                                    "audio"
                                    "mute"
                                ];
                            };
                            "XF86AudioMicMute" = {
                                _props.allow-when-locked = true;
                                spawn = [
                                    "dms"
                                    "ipc"
                                    "call"
                                    "audio"
                                    "micmute"
                                ];
                            };

                            "XF86MonBrightnessUp" = {
                                _props.allow-when-locked = true;
                                spawn = [
                                    "dms"
                                    "ipc"
                                    "call"
                                    "brightness"
                                    "increment"
                                    "5"
                                    ""
                                ];
                            };
                            "XF86MonBrightnessDown" = {
                                _props.allow-when-locked = true;
                                spawn = [
                                    "dms"
                                    "ipc"
                                    "call"
                                    "brightness"
                                    "decrement"
                                    "5"
                                    ""
                                ];
                            };

                            "Mod+Escape" = {
                                _props.hotkey-overlay-title = "Lock the screen";
                                spawn = [
                                    "dms"
                                    "ipc"
                                    "lock"
                                    "lock"
                                ];
                            };
                        };

                        _children = [
                            {
                                layer-rule._children = [
                                    { match._props.namespace = "quickshell"; }
                                    { place-within-backdrop = true; }
                                ];
                            }
                            {
                                layer-rule._children = [
                                    { match._props.namespace = "^dms:.*"; }
                                    { background-effect.xray = false; }
                                ];
                            }
                            {
                                window-rule._children = [
                                    { match._props.app-id = "org.quickshell$"; }
                                    { open-floating = true; }
                                ];
                            }
                            {
                                layer-rule._children = [
                                    { match._props.namespace = "dms:notification-popup"; }
                                    { block-out-from = "screencast"; }
                                ];
                            }
                        ];
                    };

                    xdg.configFile = {
                        "DankMaterialShell/settings.json".source = jsonFormat.generate "dms-settings.json" (
                            commonSettings // settings
                        );
                        "DankMaterialShell/plugin_settings.json".source = jsonFormat.generate "dms-plugin-settings.json" (
                            commonPluginSettings // pluginSettings
                        );
                        "DankMaterialShell/themes/gruvboxMaterial.json".source = ./themes/gruvboxMaterial.json;
                    };
                };
        };
}
