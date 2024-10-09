{ channels, ... }:

final: prev: {
    limo = (channels.limo.limo.override { unrar = prev.unrar.overrideAttrs { meta.license = []; }; });
}
