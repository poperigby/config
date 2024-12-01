{ channels, ... }:

final: prev: {
    limo = (channels.limo.limo.override { withUnrar = true; unrar = prev.unrar.overrideAttrs { meta.license = []; }; }).overrideAttrs(old: {
        src = prev.fetchFromGitHub {
            owner = "limo-app";
            repo = "limo";
            rev = "v1.0.9";
            hash = "sha256-ytSlR6JhR7qYT/jCbTthHWc+YOX4AbJs9a4GRdgHj5c=";
        };
    });
}
