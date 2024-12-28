{ ... }:

final: prev: {
  nifskope = prev.nifskope.overrideAttrs (oldAttrs: {
    version = "v2.0.dev9-20241112";

    src = prev.fetchFromGitHub {
      owner = "fo76utils";
      repo = oldAttrs.pname;
      rev = "c268a902ba4ef52b2824504a53815fa5bbdc5b5e";
      hash = "sha256-sRK7FikPH0S7qDJGUKW4+riybykrI9JbPRk3z+GUTDg=";
      deepClone = true;
      fetchSubmodules = true;
    };

    patches = [ ];

    buildInputs = with prev; [
      qt6.qtbase
      qt6.qtwayland
      qt6.qt5compat
      libGLU
    ];

    nativeBuildInputs = with prev.qt6; [
      qmake
      wrapQtAppsHook
    ];
  });
}
