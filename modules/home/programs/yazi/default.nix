{ config, lib, pkgs, ... }:

let
  gui = config.common.home.gui.enable;
in
{
    programs.yazi = {
        enable = true;
        enableFishIntegration = true;
        keymap = {
            manager.prepend_keymap = [
            ] ++ lib.optionals gui [
                # Enable mapping for ripdrag if GUI is enabled
                {
                    on = [ "<C-n>" ];
                    exec = "shell '${pkgs.ripdrag}/bin/ripdrag $@ -x 2>/dev/null &' --confirm";
                }
            ];
        };
    };

    # Create a desktop entry for Yazi if the GUI is enabled
    xdg.desktopEntries.yazi = lib.mkIf gui {
        name = "Yazi";
        genericName = "File Browser";
        exec = "yazi";
        terminal = true;
        categories = [ "System" "FileTools" "FileManager" ];
        mimeType = [ "inode/directory" ];
    };
}
