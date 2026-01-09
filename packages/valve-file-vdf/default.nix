{
    lib,
    stdenv,
    fetchFromGitHub,
    cmake,
}:

stdenv.mkDerivation rec {
    pname = "valve-file-vdf";
    version = "1.1.0";

    src = fetchFromGitHub {
        owner = "TinyTinni";
        repo = "ValveFileVDF";
        rev = "v${version}";
        hash = "sha256-btjuCEs1M4gjIWsYLFIb+dwc4Lcd9JZnXS+Y61pZqf4=";
    };

    nativeBuildInputs = [
        cmake
    ];

    meta = {
        description = "C++ Parser and Writer for Valve Data Format (e.g. .vdf files used in steam";
        homepage = "https://github.com/TinyTinni/ValveFileVDF";
        license = lib.licenses.mit;
        mainProgram = "valve-file-vdf";
        platforms = lib.platforms.all;
    };
}
