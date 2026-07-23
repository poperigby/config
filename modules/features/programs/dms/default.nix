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
                { lib, pkgs, ... }:
                let
                    jsonFormat = pkgs.formats.json { };
                    commonSettings = builtins.fromJSON (builtins.readFile ./settings.json);
                    commonPluginSettings = builtins.fromJSON (builtins.readFile ./plugin_settings.json);
                    niriBinds = builtins.readFile ../../desktops/niri/binds.kdl;
                    dmsNiriBinds = builtins.readFile ./niri-binds.kdl;
                in
                {
                    xdg.configFile = {
                        "niri/binds.kdl".text = lib.mkForce ''
                            binds {
                            ${niriBinds}
                            ${dmsNiriBinds}
                            }
                        '';
                        "niri/config.kdl".text = lib.mkAfter ''
                            include "dms.kdl"
                        '';
                        "niri/dms.kdl".source = ./niri-rules.kdl;
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
