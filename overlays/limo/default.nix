{ channels, ... }:

final: prev: {
    limo = (channels.limo.limo.override { withUnrar = true; unrar = prev.unrar.overrideAttrs { meta.license = []; }; }).overrideAttrs(old: {
        src = prev.fetchFromGitHub {
            owner = "limo-app";
            repo = "limo";
            rev = "v1.0.8.2";
            hash = "sha256-6rv1IjWb/nrymd57CtrlAjX2KfMYlYNnfiodiRAJ1Ok=";
        };

        postInstall = '''';

        cmakeFlags = old.cmakeFlags ++ [
            "-DLIMO_INSTALL_PREFIX=${placeholder "out"}"
        ];
    });
}
