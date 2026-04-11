{ den, inputs, ... }:
{
    den.aspects.programs.provides.imv.homeManager =
        { config, ... }:
        let
            colors = config.colorScheme.palette;
        in
        {
            imports = [ inputs.nix-colors.homeManagerModules.default ];

            programs.imv = {
                enable = true;
                settings.options.background = colors.base00;
            };

            xdg.desktopEntries.imv = {
                name = "Image Viewer";
                comment = "Simple and minimalist image viewer";
                exec = "imv %f";
                icon = "multimedia-photo-viewer";
                terminal = false;
                type = "Application";
                categories = [
                    "Graphics"
                    "Viewer"
                ];
                mimeType = [
                    "image/jpeg"
                    "image/png"
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
        };

    den.aspects.programs.provides.imv-default.homeManager.xdg.mimeApps.defaultApplications =
        let
            imv = [ "imv.desktop" ];
        in
        {
            "image/jpeg" = imv;
            "image/png" = imv;
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
}
