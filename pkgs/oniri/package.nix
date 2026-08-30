{
    lib,
    rustPlatform,
    fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
    pname = "oniri";
    version = "1.3.5";

    src = fetchFromGitHub {
        owner = "Antiz96";
        repo = "oniri";
        rev = "v${version}";
        hash = "sha256-BT5KVE5zT2z4gO2GLYV+ZtCQ8e9nUegxOnhkoywnrDo=";
    };

    cargoHash = "sha256-aqFIF5DemmKZs5rTF9c8mFts5emCmeNk5UYEKCl5ilQ=";

    meta = {
        description = "Automatically maximize the only window of a niri workspace";
        homepage = "https://github.com/Antiz96/oniri";
        license = lib.licenses.gpl3Plus;
        mainProgram = "oniri";
        platforms = lib.platforms.linux;
    };
}
