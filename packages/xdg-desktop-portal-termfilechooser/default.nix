{
    fetchFromGitHub,
    inih,
    lib,
    meson,
    ninja,
    pkg-config,
    scdoc,
    stdenv,
    systemd,
    ...
}:

stdenv.mkDerivation rec {
    pname = "xdg-desktop-portal-termfilechooser";
    version = "0.1.0";

    src = fetchFromGitHub {
        owner = "boydaihungst";
        repo = pname;
        rev = "753f986144f9f1891e701b5d4996740318f76f4c";
        hash = "sha256-LUO5ej0c/bdSxZU4RIw3nzPqQmWCGWhmOTQC5RVz5n4=";
    };

    nativeBuildInputs = [
        meson
        ninja
        pkg-config
    ];

    buildInputs = [
        inih
        systemd
        scdoc
    ];

    mesonFlags = [
        "-Dsd-bus-provider=libsystemd"
    ];

    meta = {
        description = "xdg-desktop-portal backend for choosing files with your favorite file chooser";
        homepage = "https://github.com/boydaihungst/xdg-desktop-portal-termfilechooser";
        license = lib.licenses.mit;
        platforms = lib.platforms.linux;
    };
}
