{ config, lib, ... }:

let
    cfg = config.poperigby.programs.mpv;
in
{
    options.poperigby.programs.mpv.enable = lib.mkEnableOption "Enable MPV";

    config = lib.mkIf cfg.enable {
        programs.mpv = {
            enable = true;
        };

        xdg.mimeApps.defaultApplications = let
            mpv = "mpv.desktop";
        in {
            "video/quicktime" = mpv;
        };
    };
}
