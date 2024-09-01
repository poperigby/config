{ ... }:

final: prev: {
    scenefx = prev.scenefx.overrideAttrs (old: {
        depsBuildBuild = [ prev.pkg-config ];
        nativeBuildInputs = old.nativeBuildInputs ++ [
            prev.wayland-scanner
        ];
    });
    swaylock-effects = prev.swaylock-effects.overrideAttrs (old: {
        depsBuildBuild = [ prev.pkg-config ];
        nativeBuildInputs = old.nativeBuildInputs ++ [
            prev.wayland-scanner
        ];
    });
}
