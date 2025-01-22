{ ... }:

final: prev: {
  limo = (prev.limo.override { withUnrar = true; }).overrideAttrs (old: {
    src = prev.fetchFromGitHub {
      owner = "limo-app";
      repo = "limo";
      rev = "ef8668a218e6c9c18f4fd627661f28288e7ad47c";
      hash = "sha256-Q/7Xq9kCFlGCZ3ha6ogZBqCvOryUDRY8MnxRglM9YO8=";
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
