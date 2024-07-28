{ pkgs, ... }:

{
    poperigby = {
        suites = {
            common.enable = true;
            gaming.enable = true;
            gui = {
                enable = true;
                adaptiveSync = false;
                resolution = "2560x1440";
                refreshRate = 165;
                wallpaper = ./wallpaper.jpg;
            };
        };
        services.ludusavi.settings = {
                manifest.url = "https://raw.githubusercontent.com/mtkennerly/ludusavi-manifest/master/data/manifest.yaml";
                # Game library roots from which saves will be backed up
                roots = [
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
                customGames = [
                    {
                        name = "OpenMW";
                        files = [ "/home/cassidy/.local/share/openmw/saves" ];
                    }
                ];
                backup.path = "~/.local/state/backups/ludusavi";
                restore.path = "~/.local/state/backups/ludusavi";

        };
    };

    # 3D printer slicer
    home.packages = [ pkgs.super-slicer-latest ];

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    home.stateVersion = "23.11";
}
