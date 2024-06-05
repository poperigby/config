{ ... }:

{
    poperigby = {
        suites = {
            common.enable = true;
            gaming = {
                enable = true;
                # Game library roots to be backed up
                libraryRoots = [
                    {
                        path = "/home/cassidy/.local/share/Steam";
                        store = "steam";
                    }
                    {
                        path = "/home/cassidy/.config/heroic";
                        store = "heroic";
                    }
                    {
                        path = "/mnt/ssd0/SteamLibrary";
                        store = "steam";
                    }
                    {
                        path = "/mnt/hdd0/SteamLibrary";
                        store = "steam";
                    }
                ];
            };
            gui = {
                enable = true;
                adaptiveSync = true;
                resolution = "2560x1440";
                refreshRate = 165;
                wallpaper = ./wallpaper.jpg;
            };
        };
    };

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    home.stateVersion = "23.11";
}
