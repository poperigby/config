{ config, lib, ... }:

let
    cfg = config.poperigby.desktops.sway;
in
{
    config = lib.mkIf cfg.enable {
        wayland.windowManager.sway.config = {
                # Floating window rules
                floating = {
                    # Show titlebar for floating windows
                    titlebar = true;
                    # Windows to make floating
                    criteria = [
                        # Steam
                        {
                            title = "Friends List";
                        }
                        {
                            title = "Steam Settings";
                        }
                        {
                            title = "Create or select new Steam library folder";
                        }
                        # Blueman
                        {
                            app_id = ".blueman-manager-wrapped";
                        }
                        # pwvucontrol
                        {
                            app_id = "com.saivert.pwvucontrol";
                        }
                        # Firefox
                        {
                            title = "Extension: (Bitwarden Password Manager) - Bitwarden — Mozilla Firefox";
                        }
                        # xEdit
                        {
                           title = "Please check or double click the module that you want to Quick Auto Clean";
                        }
                        {
                            title = "Which files do you want to add this record to?";
                        }
                        {
                            title = "Save changed files:";
                        }
                        {
                            title = "Create ModGroup...";
                        }
                        {
                            title = "In which module's .modgroups file should the new ModGroup be stored?";
                        }
                        {
                            title = "Reloading ModGroups - Which ModGroups do you want to activate?";
                        }
                        {
                            title = "Which files do you want to add these records to?";
                        }
                        {
                            title = "Module Selection";
                        }
                    ];
                };
        };
    };
}
