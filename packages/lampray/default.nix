{
    SDL2,
    cmake,
    curl,
    fetchFromGitHub,
    lib,
    lz4,
    makeWrapper,
    ninja,
    p7zip,
    pkg-config,
    stdenv,
    zenity,
    ...
}:

stdenv.mkDerivation rec {
    pname = "lampray";
    version = "1.3.2";

    src = fetchFromGitHub {
        owner = "CHollingworth";
        repo = "Lampray";
        rev = "v${version}";
        hash = "sha256-q6XoGbP1PvNY/0j7EhIHE3nY/iwmxyb/JkgNEp90PZU=";
    };

    nativeBuildInputs = [
        cmake
        makeWrapper
        ninja
        pkg-config
    ];

    buildInputs = [
       SDL2
       curl
       p7zip
       zenity
       lz4
    ];

    CXXFLAGS = [ "-Wno-format-security" ];

    prePatch = ''
        sed -i 's|const lampString baseDataPath = "Lamp_Data/";|const lampString baseDataPath = ((std::string)std::getenv("HOME")) + "/.lamp/";|g' Lampray/Control/lampConfig.h
    '';

    installPhase = ''
        runHook preInstall

        install -D -m 0755 Lampray $out/bin/${pname}

        wrapProgram $out/bin/${pname} --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ lz4 ]}

        runHook postInstall
    '';

    meta = {
        description = "Linux Application Modding Platform. A native Linux mod manager";
        homepage = "https://github.com/CHollingworth/Lampray";
        changelog = "https://github.com/CHollingworth/Lampray/blob/${src.rev}/CHANGELOG.md";
        license = lib.licenses.unlicense;
        mainProgram = "lampray";
        platforms = lib.platforms.all;
    };
}
