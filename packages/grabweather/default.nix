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
        hash = lib.fakeHash;
    };

    cargoSha256 = lib.fakeHash;

    meta = with lib; {
        description = "A simple tool that returns the current weather.";
        homepage = "https://codeberg.org/PopeRigby/grabweather";
        license = licenses.gpl3;
    };
}
