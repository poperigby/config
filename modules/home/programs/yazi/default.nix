{ config, lib, pkgs, ... }:

let
  cfg = config.poperigby.programs.yazi;
  gui = config.poperigby.suites.gui.enable;
in
{
    options.poperigby.programs.yazi = {
        enable = lib.mkEnableOption "Enable Yazi file explorer";
        default = lib.mkEnableOption "Make Yazi the default file explorer";
    };

    config = lib.mkIf cfg.enable {
        programs.yazi = {
            enable = true;
            enableFishIntegration = true;
            theme = builtins.fromTOML (builtins.readFile ./theme.toml);
            keymap = {
                manager.prepend_keymap = [
                ] ++ lib.optionals gui [
                    # Enable mapping for ripdrag if GUI is enabled
                    {
                        on = [ "<C-n>" ];
                        run = "shell '${pkgs.ripdrag}/bin/ripdrag $@ -x 2>/dev/null &' --confirm";
                    }
                ];
            };
        };

        # Create a desktop entry for Yazi if the GUI is enabled
        xdg.desktopEntries.yazi = lib.mkIf gui {
            name = "Yazi";
            genericName = "File Browser";
            exec = "yazi %f";
            icon = ./icon.png;
            terminal = true;
            categories = [ "System" "FileTools" "FileManager" ];
            mimeType = [ "inode/directory" ];
        };

        xdg.mimeApps.defaultApplications = lib.mkIf cfg.default {
            "inode/directory" = "yazi.desktop";
        };
    };
}
