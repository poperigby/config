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
          rev = "d995e58a71511fc247652b8ddfe255cefd4d51c1";
          hash = "sha256-T05Fgg0hjxutlSPAdule1HQa9zfr9QMEvbmq/K4axdc=";
        };
      });
}
