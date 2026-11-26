{ den, inputs, ... }:
{
    flake-file.inputs = {
        noctalia = {
            url = "github:noctalia-dev/noctalia";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        noctalia-greeter = {
            url = "github:noctalia-dev/noctalia-greeter";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    den.aspects.shells.provides.noctalia =
        {
            wallpaper ? null,
        }:
        {
            includes = [
                (den.aspects.shells._.noctalia.settings {
                    inherit wallpaper;
                })
            ];

            nixos =
                {
                    config,
                    lib,
                    pkgs,
                    ...
                }:
                let
                    inherit (builtins) attrValues getAttr hasAttr;
                    inherit (lib) concatMap optional;

                    configFile = "noctalia/config.toml";
                    noctaliaConfigTriggers = concatMap (
                        userConfig:
                        optional (hasAttr configFile userConfig.xdg.configFile) (getAttr configFile userConfig.xdg.configFile)
                        .source
                    ) (attrValues (config.home-manager.users or { }));
                in
                {
                    imports = [
                        inputs.noctalia.nixosModules.default
                        inputs.noctalia-greeter.nixosModules.default
                    ];

                    programs.noctalia = {
                        enable = true;
                        systemd.enable = true;

                        # Enables NetworkManager, Bluetooth, UPower, and a power profile service.
                        recommendedServices.enable = true;
                    };

                    services.displayManager.noctalia-greeter.enable = true;

                    environment.systemPackages = [ pkgs.ddcutil ];
                    hardware.i2c.enable = true;
                    systemd.user.services.noctalia = {
                        restartTriggers = noctaliaConfigTriggers;
                        # Noctalia can hang on exit while waiting on a pending Secret Service prompt.
                        serviceConfig.TimeoutStopSec = "5s";
                    };

                    nix.settings = {
                        extra-substituters = [ "https://noctalia.cachix.org" ];
                        extra-trusted-public-keys = [
                            "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
                        ];
                    };

                };
            homeManager = { ... }: {
                wayland.windowManager.niri.settings = {
                    binds = {
                        "Mod+Space" = {
                            _props.hotkey-overlay-title = "Open the application launcher";
                            spawn = [
                                "noctalia"
                                "msg"
                                "panel-toggle"
                                "launcher"
                            ];
                        };
                        "Mod+N" = {
                            _props.hotkey-overlay-title = "Notification Center";
                            spawn = [
                                "noctalia"
                                "msg"
                                "panel-toggle"
                                "control-center"
                                "notifications"
                            ];
                        };
                        "Mod+V" = {
                            _props.hotkey-overlay-title = "Clipboard Manager";
                            spawn = [
                                "noctalia"
                                "msg"
                                "panel-toggle"
                                "clipboard"
                            ];
                        };
                        "XF86AudioRaiseVolume" = {
                            _props.allow-when-locked = true;
                            spawn = [
                                "noctalia"
                                "msg"
                                "volume-up"
                            ];
                        };
                        "XF86AudioLowerVolume" = {
                            _props.allow-when-locked = true;
                            spawn = [
                                "noctalia"
                                "msg"
                                "volume-down"
                            ];
                        };
                        "XF86AudioMute" = {
                            _props.allow-when-locked = true;
                            spawn = [
                                "noctalia"
                                "msg"
                                "volume-mute"
                            ];
                        };
                        # "XF86AudioMicMute" = {
                        #     _props.allow-when-locked = true;
                        #     spawn = [
                        #         "noctalia"
                        #         "msg"
                        #         "call"
                        #         "audio"
                        #         "micmute"
                        #     ];
                        # };
                        "XF86MonBrightnessUp" = {
                            _props.allow-when-locked = true;
                            spawn = [
                                "noctalia"
                                "msg"
                                "brightness-up"
                            ];
                        };
                        "XF86MonBrightnessDown" = {
                            _props.allow-when-locked = true;
                            spawn = [
                                "noctalia"
                                "msg"
                                "brightness-down"
                            ];
                        };
                        "Mod+Escape" = {
                            _props.hotkey-overlay-title = "Lock the screen";
                            spawn = [
                                "noctalia"
                                "msg"
                                "session"
                                "lock"
                            ];
                        };
                    };

                    _children = [
                        {
                            # Stationary wallpaper
                            layer-rule._children = [
                                { match._props.namespace = "^noctalia-wallpaper"; }
                                { place-within-backdrop = true; }
                            ];
                        }
                        {
                            # Disable xray on all our surfaces so it looks more realistic.
                            # Noctalia publishes blur regions automatically when ext-background-effects is available.
                            layer-rule._children = [
                                { match._props.namespace = "^noctalia-(bar-[^\"]+|notification|dock|panel|attached-panel|osd)$"; }
                                { background-effect.xray = false; }
                            ];
                        }
                        {
                            # Open settings window floating
                            window-rule._children = [
                                { match._props.app-id = "dev.noctalia.Noctalia"; }
                                { open-floating = true; }
                            ];
                        }
                    ];
                };
            };
        };
}
