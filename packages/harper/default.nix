{
    lib,
    rustPlatform,
    fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
    pname = "harper";
    version = "0.9.0";

    src = fetchFromGitHub {
        owner = "elijah-potter";
        repo = "harper";
        rev = "v${version}";
        hash = "sha256-LPDs+PUgHzrAT6Y3+YyA0FDbqyc31+cZR5v262kFxRI=";
    };

    cargoHash = "sha256-5go9yQwhZ19mGIfaBEeswbElcW9Z1hSi5+XN1Lc/3SU=";

    meta = with lib; {
        description = "The Grammar Checker for Developers";
        homepage = "https://github.com/elijah-potter/harper";
        license = licenses.asl20;
        mainProgram = "harper-ls";
    };
}

