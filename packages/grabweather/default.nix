{
    fetchgit,
    rustPlatform,
    lib,
    ...
}:

rustPlatform.buildRustPackage {
    pname = "grabweather";
    version = "0.1.0";

    src = fetchgit {
        url = "https://codeberg.org/PopeRigby/grabweather";
        hash = "sha256-q1iik6VnHwWw+jo/04t6HPN2xy5+oIMk4aJY4+35nQA=";
    };

    cargoSha256 = "sha256-CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC=";

    meta = with lib; {
        description = "A simple tool that returns the current weather.";
        homepage = "https://codeberg.org/PopeRigby/grabweather";
        license = licenses.gpl3;
    };
}
