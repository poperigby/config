{ config, lib, pkgs, ... }:

let
  cfg = config.poperigby.programs.yazi;
  desktop = config.poperigby.suites.desktop.enable;
in
{
    options.poperigby.programs.yazi.enable = lib.mkEnableOption "Enable Yazi file explorer";

    config = lib.mkIf cfg.enable {
        programs.yazi = {
            enable = true;
            enableFishIntegration = true;
            keymap = {
                manager.prepend_keymap = [
                ] ++ lib.optionals desktop [
                    # Enable mapping for ripdrag if desktop GUI is enabled
                    {
                        on = [ "<C-n>" ];
                        exec = "shell '${pkgs.ripdrag}/bin/ripdrag $@ -x 2>/dev/null &' --confirm";
                    }
                ];
            };
        };

        # Create a desktop entry for Yazi if the desktop GUI is enabled
        xdg.desktopEntries.yazi = lib.mkIf desktop {
            name = "Yazi";
            genericName = "File Browser";
            exec = "yazi";
            terminal = true;
            categories = [ "System" "FileTools" "FileManager" ];
            mimeType = [ "inode/directory" ];
        };
    };
}
