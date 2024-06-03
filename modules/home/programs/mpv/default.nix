{ config, lib, pkgs, ... }:

let
    cfg = config.poperigby.programs.mpv;
in
{
    options.poperigby.programs.mpv.enable = lib.mkEnableOption "Enable MPV";

    config = lib.mkIf cfg.enable {
        programs.mpv = {
            enable = true;
            config = {
                # Require for `thumbnail` plugin
                osc = "no";
#
            };
            scripts = with pkgs.mpvScripts; [
                # Display thumbnails in the seek bar
                thumbnail
                # Keybinding cheat sheet
                mpv-cheatsheet
            ];
        };

        xdg.mimeApps.defaultApplications = let
            mpv = "mpv.desktop";
        in {
            "video/quicktime" = mpv;
        };
    };
}
