{ config, inputs, lib, ... }:

let
    cfg = config.poperigby.programs.imv;
    colors = config.colorScheme.palette;
in
{
    options.poperigby.programs.imv = {
        enable = lib.mkEnableOption "Enable imv";
        default = lib.mkEnableOption "Make imv the default image viewer";
    };

    imports = [ inputs.nix-colors.homeManagerModules.default ];

    config = lib.mkIf cfg.enable {
        programs.imv = {
            enable = true;
            settings = {
                options = {
                    background = colors.base00;
                };
            };
        };

        xdg.desktopEntries.imv = {
            name = "Image Viewer";
            comment = "Simple and minimalist image viewer";
            exec = "imv %f";
            icon = "multimedia-photo-viewer";
            terminal = false;
            type = "Application";
            categories = [ "Graphics" "Viewer" ];
            mimeType = [
                "image/jpeg"
                "image/png"
                "image/gif"
                "image/bmp"
                "image/x-xpixmap"
                "image/tiff"
                "image/x-portable-bitmap"
                "image/x-portable-graymap"
                "image/x-portable-pixmap"
                "image/x-portable-anymap"
                "image/x-psd"
                "image/svg+xml"
            ];
        };

        xdg.mimeApps.defaultApplications = let
            imv = [ "imv.desktop" ];
        in lib.mkIf cfg.default {
            "image/jpeg" = imv;
            "image/png" = imv;
            "image/gif" = imv;
            "image/bmp" = imv;
            "image/x-xpixmap" = imv;
            "image/tiff" = imv;
            "image/x-portable-bitmap" = imv;
            "image/x-portable-graymap" = imv;
            "image/x-portable-pixmap" = imv;
            "image/x-portable-anymap" = imv;
            "image/x-psd" = imv;
            "image/svg+xml" = imv;
        };
    };
}
