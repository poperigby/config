{ channels, ... }:

final: prev: {
    limo = (channels.limo.limo.override { unrar = prev.unrar.overrideAttrs { meta.license = []; }; }).overrideAttrs {
        postInstall = ''
            mkdir -p $out/share/icons/hicolor/512x512/apps
            cp ../flatpak/io.github.limo_app.limo.png $out/share/icons/hicolor/512x512/apps

            mkdir -p $out/share/applications
            cp ../flatpak/io.github.limo_app.limo.desktop $out/share/applications
        '';
    };
}
