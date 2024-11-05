{ ... }:

final: prev: {
    _7zz = prev._7zz.overrideAttrs(old: {
        makeFlags = old.makeFlags ++ [ "USE_ASM=" ]; 
    });
}
