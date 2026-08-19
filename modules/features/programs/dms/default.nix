{
    self,
    inputs,
    lib,
    ...
}:
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
    flake-file.inputs = {
        dank-material-shell = {
            url = "github:AvengeMedia/DankMaterialShell";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        dms-plugin-registry = {
            url = "github:AvengeMedia/dms-plugin-registry";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    den.aspects.programs.provides.dms =
        {
            settings ? { },
            wallpaper ? null,
        }:
        {
            nixos =
                { config, pkgs, ... }:
                {
                    imports = [ inputs.dank-material-shell.nixosModules.dank-material-shell ];

                    programs.dank-material-shell = {
                        enable = true;
                        package = pkgs.dms-shell;
                        quickshell.package = pkgs.quickshell;

                        systemd = {
                            enable = true;
                            restartIfChanged = true;
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
                        package = config.programs.dank-material-shell.package;
                        quickshell.package = config.programs.dank-material-shell.quickshell.package;
                        compositor.name = "niri";
                        configHome = "/home/cassidy";
                    };
                };

            homeManager =
                {
                    config,
                    osConfig,
                    lib,
                    pkgs,
                    ...
                }:
                let
                    sshConnectionHosts = sshHostsFor osConfig.networking.hostName;

                    commonSettings = builtins.fromJSON (builtins.readFile ./settings.json);
                in
                {
                    imports = [ inputs.dank-material-shell.homeModules.dank-material-shell ];

                    programs.dank-material-shell = {
                        enable = true;
                        package = osConfig.programs.dank-material-shell.package;

                        plugins = {
                            calculator = {
                                src = pkgs.fetchFromGitHub {
                                    owner = "poperigby";
                                    repo = "DankCalculator";
                                    rev = "numbat-debounce";
                                    hash = "sha256-K/24VCf+IzNyck50Aco6kJfBE4Lji3ue3UCd5dBBRc8=";
                                };
                                settings = {
                                    # enabled = true;
                                    trigger = "=";
                                    noTrigger = false;
                                    persistHistoryOnFile = true;
                                    calcEngine = "numbat";
                                    numbatDebounceMs = "100000";
                                };

                            };
                            emojiLauncher = {
                                src = pkgs.applyPatches {
                                    src = pkgs.fetchFromGitHub {
                                        owner = "devnullvoid";
                                        repo = "dms-emoji-launcher";
                                        rev = "main";
                                        hash = "sha256-fmIddCvACwO8wbAtLBMtDnEXXQJjb7+o2s4jW3f8VIU=";
                                    };
                                    patches = [ ./patches/emoji-launcher-history-state.patch ];
                                };
                                settings = {
                                    # enabled = true;
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
                            sshConnections = {
                                src =
                                    pkgs.applyPatches {
                                        src = pkgs.fetchFromGitHub {
                                            owner = "merdely";
                                            repo = "dms-plugins";
                                            rev = "b45d16f30f56c16371d93ecf54c3d0b4c23a24a5";
                                            hash = "sha256-OVecni81Qd3OonFRGASAg+tl1woXdiUIhovczWnh4Uc=";
                                        };
                                        patches = [
                                            ./patches/ssh-connections-wezterm-ssh.patch
                                            ./patches/ssh-connections-history-state.patch
                                        ];
                                    }
                                    + "/sshConnections";
                                settings = {
                                    # enabled = true;
                                    trigger = ":";
                                    pasteOnSelect = true;
                                };
                            };
                        };

                        settings = commonSettings // settings;
                    };

                    home.activation.dmsWallpaperPath = lib.mkIf (wallpaper != null) (
                        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
                            sessionFile="${config.xdg.stateHome}/DankMaterialShell/session.json"
                            ${pkgs.coreutils}/bin/mkdir -p "$(${pkgs.coreutils}/bin/dirname "$sessionFile")"

                            tmp="$(${pkgs.coreutils}/bin/mktemp "$sessionFile.tmp.XXXXXX")"
                            trap '${pkgs.coreutils}/bin/rm -f "$tmp"' EXIT

                            if [ -s "$sessionFile" ]; then
                                ${lib.getExe pkgs.jq} --arg wallpaperPath ${lib.escapeShellArg (toString wallpaper)} \
                                    '. + { wallpaperPath: $wallpaperPath }' \
                                    "$sessionFile" > "$tmp"
                            else
                                ${lib.getExe pkgs.jq} --null-input --arg wallpaperPath ${lib.escapeShellArg (toString wallpaper)} \
                                    '{ wallpaperPath: $wallpaperPath }' > "$tmp"
                            fi

                            ${pkgs.coreutils}/bin/mv "$tmp" "$sessionFile"
                            trap - EXIT
                        ''
                    );

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
