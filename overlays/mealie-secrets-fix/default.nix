# https://github.com/NixOS/nixpkgs/pull/324034

{ ... }:

final: prev: {
    mealie = prev.mealie.overrideAttrs (oldAttrs: {
        patches = [
            (final.fetchpatch {
                url = "https://github.com/mealie-recipes/mealie/commit/65ece35966120479db903785b22e9f2645f72aa4.patch";
                hash = "sha256-4Nc0dFJrZ7ElN9rrq+CFpayKsrRjRd24fYraUFTzcH8=";
            })
        ];
    });
}
