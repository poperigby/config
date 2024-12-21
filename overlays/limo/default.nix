{ channels, ... }:

final: prev: {
  limo =
    (channels.limo.limo.override {
      withUnrar = true;
      unrar = prev.unrar.overrideAttrs { meta.license = [ ]; };
    }).overrideAttrs
      (old: {
        src = prev.fetchFromGitHub {
          owner = "limo-app";
          repo = "limo";
          rev = "011a7c9ae910db420c10cf1b1c3bcdaa22f91bc8";
          hash = "sha256-NSlZRFkLq3Ks6h4imDcouyiouKYeY7AK1U6a4CXaaA0=";
        };
      });
}
