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
        postPatch = oldAttrs.postPatch + ''
            substituteInPlace mealie/services/backups_v2/alchemy_exporter.py \
                --replace-fail '"script_location", path.join(PROJECT_DIR, "alembic")' '"script_location", "${oldAttrs.src}/alembic"'
        '';
    });
}
