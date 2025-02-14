{ ... }:

final: prev: {
  limo = (prev.limo.override { withUnrar = true; }).overrideAttrs (old: {
    src = prev.fetchFromGitHub {
      owner = "limo-app";
      repo = "limo";
      rev = "662e695c8c06d84fbe71a98caa62954c3bc8a823";
      hash = "sha256-fzqIZ/BqOpPjo18qi4VidGg1ruhQLqfwoA/hidGPEao=";
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
