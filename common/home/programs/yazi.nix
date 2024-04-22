    # Create a desktop entry for Yazi if the GUI is enabled
    xdg.desktopEntries.yazi = lib.mkIf config.common.home.gui.enable {
        name = "Yazi";
        genericName = "File Browser";
        exec = "yazi";
        terminal = true;
        categories = [ "System" "FileTools" "FileManager" ];
        mimeType = [ "inode/directory" ];
    };
