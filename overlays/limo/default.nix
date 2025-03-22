{ ... }:

final: prev: {
  limo = (prev.limo.override { withUnrar = true; }).overrideAttrs (old: {
    src = prev.fetchFromGitHub {
      owner = "limo-app";
      repo = "limo";
      rev = "0686d1096692636c17f4ce9bd28f33c48fe4067e";
      hash = "sha256-tLt0MKIP9+EIDo5goP+DVyOfgueAaE65JeSr4tcrtTY=";
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
