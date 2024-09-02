{ config, lib, pkgs, ... }:

let
    inherit (lib)
        getExe
        mkEnableOption
        mkIf
        mkMerge
        optionals
    ;

    cfg = config.poperigby.programs.yazi;
    gui = config.poperigby.suites.gui.enable;
in
{
    options.poperigby.programs.yazi = {
        enable = mkEnableOption "Yazi file explorer";
        default = mkEnableOption "Yazi as the default file explorer";
    };

    config = mkIf cfg.enable {
        programs.yazi = {
            enable = true;
            enableFishIntegration = true;
            theme = builtins.fromTOML (builtins.readFile ./theme.toml);
            settings = {
                manager = {
                    sort_by = "modified";
                    sort_reverse = true;
                    sort_dir_first = false;
                };
            };
            keymap = {
                manager.prepend_keymap = [
                    {
                        on = [ "g" "m" ];
                        run = "cd /run/media/$USER";
                        desc = "Go to the removable drives directory";
                    }
                ] ++ optionals gui [
                    # Enable mapping for ripdrag if GUI is enabled
                    {
                        on = [ "<C-n>" ];
                        run = "shell '${getExe pkgs.ripdrag} $@ -x 2>/dev/null &' --confirm";
                        description = "Open ripdrag for dragging and dropping";
                    }
                ];
            };
        };

        # Do some helpful desktop related tweaks if GUI suite is enabled
        xdg = mkIf gui (mkMerge [
            {
                desktopEntries.yazi = {
                    name = "Yazi";
                    genericName = "File Browser";
                    exec = "${getExe pkgs.yazi} %f";
                    icon = ./icon.png;
                    terminal = true;
                    categories = [ "System" "FileTools" "FileManager" ];
                    mimeType = [ "inode/directory" ];
                };
            }
        ]);
    };
}
