{
    lib,
    stdenv,
    fetchFromGitHub,
    pkg-config,
    hidapi,
    libusb1,
}:

stdenv.mkDerivation (finalAttrs: {
    pname = "steam-haptics-player";
    version = "1.1.0";

    src = fetchFromGitHub {
        owner = "Pixel1011";
        repo = "SteamHapticsPlayer";
        rev = "48edc5f0c9b73a225f654f5567e3701d54ca820c";
        hash = "sha256-YLunqrbSi3cLxjFoD/Rk03hNKspOlj8eR9bDYwvjto4=";
    };

    nativeBuildInputs = [ pkg-config ];

    buildInputs = [
        hidapi
        libusb1
    ];

    installPhase = ''
        runHook preInstall
        install -Dm755 steam-haptics-player $out/bin/steam-haptics-player
        runHook postInstall
    '';

    meta = {
        description = "Allows stereo audio to be streamed from a file to the haptics of a Steam controller (2026)";
        homepage = "https://github.com/Pixel1011/SteamHapticsPlayer";
        license = lib.licenses.bsd3;
        maintainers = with lib.maintainers; [ PopeRigby ];
        mainProgram = "steam-haptics-player";
        platforms = lib.platforms.linux;
    };
})
