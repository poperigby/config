{ ... }:

final: prev: {
  limo = (prev.limo.override { withUnrar = true; }).overrideAttrs (old: {
    src = prev.fetchFromGitHub {
      owner = "limo-app";
      repo = "limo";
      rev = "9b805ab9243a483bfb084e556e2247d75d7c29ad";
      hash = "sha256-fK28D7ngOJ9Zjlzdb9QUd8PNWrBdQr2wSk1mV/k6I+8=";
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
