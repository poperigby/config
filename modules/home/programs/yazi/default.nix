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
            plugins = {
                "smart-enter" = ./plugins/smart-enter;
            };
            keymap = {
                manager.prepend_keymap = [
                    {
                        on = [ "g" "m" ];
                        run = "cd /run/media/$USER";
                        desc = "Go to the removable drives directory";
                    }
                    {
                        on   = [ "l" ];
                        run  = "plugin --sync smart-enter";
                        desc = "Enter the child directory, or open the file";
                    }
                ] ++ lib.optionals gui [
                    # Enable mapping for ripdrag if GUI is enabled
                    {
                        on = [ "<C-n>" ];
                        run = "shell '${pkgs.ripdrag}/bin/ripdrag $@ -x 2>/dev/null &' --confirm";
                        description = "Open ripdrag for dragging and dropping";
                    }
                ];
            };
        };

        # Do some helpful desktop related tweaks if GUI suite is enabled
        xdg = lib.mkIf gui (lib.mkMerge [
            {
                desktopEntries.yazi = {
                    name = "Yazi";
                    genericName = "File Browser";
                    exec = "${pkgs.yazi}/bin/yazi %f";
                    icon = ./icon.png;
                    terminal = true;
                    categories = [ "System" "FileTools" "FileManager" ];
                    mimeType = [ "inode/directory" ];
                };
            }
        ]);
    };
}
