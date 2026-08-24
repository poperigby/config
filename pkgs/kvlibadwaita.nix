{
    fetchFromGitHub,
    stdenvNoCC,
    ...
}:

stdenvNoCC.mkDerivation {
    pname = "kvlibadwaita";
    version = "0-unstable-2025-06-28";

    src = fetchFromGitHub {
        owner = "GabePoel";
        repo = "KvLibadwaita";
        rev = "1f4e0bec44b13dabfa1fe4047aa8eeaccf2f3557";
        hash = "sha256-jCXME6mpqqWd7gWReT04a//2O83VQcOaqIIXa+Frntc=";
    };

    installPhase = ''
        runHook preInstall

        mkdir -p "$out/share/Kvantum"
        cp -r src/KvLibadwaita "$out/share/Kvantum/"

        runHook postInstall
    '';
}
