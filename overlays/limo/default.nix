{ ... }:

final: prev: {
  limo = (prev.limo.override { withUnrar = true; }).overrideAttrs (old: {
    src = prev.fetchFromGitHub {
      owner = "limo-app";
      repo = "limo";
      rev = "3d2b8d2a5ff8f9a0a3af4ae11cb414819b0cd0bf";
      hash = "sha256-poYdlPQnV2+GYUGBYM95Q7Aj0IpwfVoqCSDTV+unjvo=";
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
