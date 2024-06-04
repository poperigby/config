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
                # UOSC already provides seeking & volume indicators
                osd-bar = "no";
                # Makes UI less choppy
                video-sync = "display-resample";
            };
            scripts = with pkgs.mpvScripts; [
                # Fancy UI
                uosc
                # Shows thumbnails in timeline (integrates with UOSC)
                thumbfast
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
