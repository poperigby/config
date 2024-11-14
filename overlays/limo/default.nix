{ channels, ... }:

final: prev: {
    limo = (channels.limo.limo.override { withUnrar = true; unrar = prev.unrar.overrideAttrs { meta.license = []; }; });
}
