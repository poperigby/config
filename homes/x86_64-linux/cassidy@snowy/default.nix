{ lib, pkgs, ... }:

let
    inherit (lib) getExe;
    inherit (pkgs) fetchFromGitHub;
in
{
    imports = [ ./cosmic.nix ];

    custom = {
        # desktops.sway.enable = true;
        suites = {
            common.enable = true;
            gaming = {
                enable = true;
                bethesda = true;
            };
            gui = {
                enable = true;
                resolution = "2560x1440";
                refreshRate = 165;
                vrr = true;
                wallpaper = ./wallpaper.jpg;
                colorProfileFile = ./gigabyte_m27q.icc;
            };
        };
        services.ludusavi.settings = {
            manifest.url = "https://raw.githubusercontent.com/mtkennerly/ludusavi-manifest/master/data/manifest.yaml";
            # Game library roots from which saves will be backed up
            roots = [
                {
                    path = "~/.local/share/Steam";
                    store = "steam";
                }
                {
                    path = "~/.config/heroic";
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
                    files = [ "~/.local/share/openmw/saves" ];
                }
                {
                    name = "GZDoom";
                    files = [ "~/.config/gzdoom/savegames" ];
                }
            ];
            backup.path = "~/.local/state/backups/ludusavi";
            restore.path = "~/.local/state/backups/ludusavi";
        };
        programs.thunderbird.enable = true;
        users.cassidy.enable = true;
    };

    # Controls Corsair hardware
    wayland.windowManager.sway.config.startup = [
        {
            command = "${getExe pkgs.ckb-next} --background";
        }
    ];

    home.packages = with pkgs; [
        pkgsRocm.blender
        er-patcher
    ];

    home.file.morrowindBlenderPlugin = {
        source = fetchFromGitHub {
            owner = "Greatness7";
            repo = "io_scene_mw";
            rev = "0.8.103";
            hash = "sha256-f1PgjSs6jU99oqEJgOwb/wX8gVW+2DNgS+kkeka/Mo0=";
        };
        target = ".config/blender/4.3/scripts/addons/io_scene_mw";
        recursive = true;
    };
}
