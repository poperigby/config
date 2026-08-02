{ self, lib, ... }:
let
    # Determines whether a host can be SSHed to
    isSshTarget =
        _: system:
        let
            cfg = system.config;
        in
        # Installer ISOs also enable SSH, but they are not persistent machines to connect
        # to, so exclude image builds. We can see if a host is an image by checking if
        # it has `image.fileName` set.
        (cfg.services.openssh.enable or false) && !(cfg.image ? fileName);

    # Builds a list of hosts that can be SSHed to.
    sshHosts = builtins.attrNames (lib.filterAttrs isSshTarget self.nixosConfigurations);

    # Builds a list of hosts that can be SSHed to, excluding the given host.
    sshHostsFor = currentHost: builtins.filter (host: host != currentHost) sshHosts;
in
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
                            emoji-unicode-picker.src = pkgs.applyPatches {
                                src = pkgs.fetchFromGitHub {
                                    owner = "devnullvoid";
                                    repo = "dms-emoji-launcher";
                                    rev = "main";
                                    hash = "sha256-fmIddCvACwO8wbAtLBMtDnEXXQJjb7+o2s4jW3f8VIU=";
                                };
                                patches = [ ./emoji-launcher-history-state.patch ];
                            };
                            sshConnections.src =
                                pkgs.applyPatches {
                                    src = pkgs.fetchFromGitHub {
                                        owner = "merdely";
                                        repo = "dms-plugins";
                                        rev = "b45d16f30f56c16371d93ecf54c3d0b4c23a24a5";
                                        hash = "sha256-OVecni81Qd3OonFRGASAg+tl1woXdiUIhovczWnh4Uc=";
                                    };
                                    patches = [
                                        ./ssh-connections-wezterm-ssh.patch
                                        ./ssh-connections-history-state.patch
                                    ];
                                }
                                + "/sshConnections";
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
                {
                    osConfig,
                    lib,
                    pkgs,
                    ...
                }:
                let
                    jsonFormat = pkgs.formats.json { };

                    commonSettings = builtins.fromJSON (builtins.readFile ./settings.json);

                    sshConnectionHosts = sshHostsFor osConfig.networking.hostName;
                    commonPluginSettings = {
                        emojiLauncher = {
                            enabled = true;
                            trigger = ":";
                            pasteOnSelect = true;
                        };

                        calculator = {
                            enabled = true;
                            trigger = "=";
                            noTrigger = false;
                            persistHistoryOnFile = true;
                            calcEngine = "numbat";
                            numbatDebounceMs = "100000";
                        };

                        sshConnections = {
                            enabled = true;
                            terminal = lib.getExe pkgs.wezterm;
                            ssh_command = "ssh";
                            # Build the launcher list from final host configs so hosts become SSH targets
                            # automatically when OpenSSH is enabled.
                            server_list = map (host: {
                                server = host;
                                options = "";
                            }) sshConnectionHosts;
                        };
                    };
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
                        "DankMaterialShell/themes/gruvboxMaterial.json".source =
                            pkgs.fetchFromGitHub {
                                owner = "AvengeMedia";
                                repo = "dms-plugin-registry";
                                rev = "bd0adca992b502178e70cc015f2a34f2b7031186";
                                hash = "sha256-b2bNAN2mBCaSfYvn/ILpf23TVnVIIyvhMMYCE3QJ13U=";
                            }
                            + "/themes/gruvbox-material/theme.json";
                    };
                };
        };
}
