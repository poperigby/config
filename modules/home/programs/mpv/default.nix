{
    config,
    lib,
    pkgs,
    ...
}:

let
    inherit (lib)
        mkEnableOption
        mkIf
        ;

    cfg = config.custom.programs.mpv;
in
{
    options.custom.programs.mpv.enable = mkEnableOption "MPV";

    config = mkIf cfg.enable {
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
                mpv-cheatsheet-ng
                # Allows controlling MPV through the MPRIS API
                mpris
            ];
            # See for available options: https://github.com/tomasklaen/uosc/blob/HEAD/src/uosc.conf
            scriptOpts.uosc = {
                # Get rid of titlebar buttons
                top_bar_controls = "no";
            };
        };

        xdg.mimeApps.defaultApplications =
            let
                mpv = "mpv.desktop";
            in
            {
                "image/gif" = mpv;
                "video/mp4" = mpv;
                "video/quicktime" = mpv;
            };
    };
}
