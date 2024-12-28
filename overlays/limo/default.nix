{ ... }:

final: prev: {
  limo = prev.limo.overrideAttrs (old: {
    src = prev.fetchFromGitHub {
      owner = "limo-app";
      repo = "limo";
      rev = "200176f6e5a8065fdef415e3ea5d3501d192d12d";
      hash = "sha256-KQD7U9sHHsxKIzMbrYqhTBUfFZpsoqiSxz5zMNIxU4o=";
    };
  });
}
