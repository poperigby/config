# https://github.com/NixOS/nixpkgs/pull/324034

{ ... }:

final: prev: {
    mealie = prev.mealie.overrideAttrs (oldAttrs: {
        patches = [
            (final.fetchpatch {
                url = "https://github.com/mealie-recipes/mealie/commit/445754c5d844ccf098f3678bc4f3cc9642bdaad6.patch";
                hash = "sha256-ZdATmSYxhGSjoyrni+b5b8a30xQPlUeyp3VAc8OBmDY=";
                revert = true;
            })
        ];
    });
}
