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
                # Enable GPU hardware decoding
                hwdec = "auto";
            };
            scripts = with pkgs.mpvScripts; [
                # Fancy UI
                uosc
                # Shows thumbnails in timeline (integrates with UOSC)
                thumbfast
                # Keybinding cheat sheet
                mpv-cheatsheet
            ];
            # See for available options: https://github.com/tomasklaen/uosc/blob/HEAD/src/uosc.conf
            scriptOpts.uosc = {
                # Get rid of titlebar buttons
                top_bar_controls = "no";
            };
        };

        xdg.mimeApps.defaultApplications = let
            mpv = "mpv.desktop";
        in {
            "video/quicktime" = mpv;
        };
    };
}
