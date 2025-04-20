{ ... }:

final: prev: {
  limo = (prev.limo.override { withUnrar = true; }).overrideAttrs (old: {
    src = prev.fetchFromGitHub {
      owner = "limo-app";
      repo = "limo";
      rev = "90d9d9eddc87b8512266da64f135ecd1e292c931";
      hash = "sha256-hgtqpP1H9+TAuP5b/Wvx4mqeYRKyaluMlyzHEmIgSqo=";
    };

    buildInputs =
      old.buildInputs
      ++ (with prev; [
        lz4
        zlib
        zstd
      ]);
  });
}
