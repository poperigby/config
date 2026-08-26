{
    lib,
    rustPlatform,
    fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
    pname = "oniri";
    version = "1.3.4";

    src = fetchFromGitHub {
        owner = "Antiz96";
        repo = "oniri";
        rev = "v${version}";
        hash = "sha256-kJTE873WwM9E8SCedACCDjTWJ4sdDsFOuIQw2KLHK5s=";
    };

    cargoHash = "sha256-aoqtaLKGflXyg+l3f1MYSOqLJILhnY8gS8ttC0wB7iw=";

    meta = {
        description = "Automatically maximize the only window of a niri workspace";
        homepage = "https://github.com/Antiz96/oniri";
        license = lib.licenses.gpl3Plus;
        mainProgram = "oniri";
        platforms = lib.platforms.linux;
    };
}
