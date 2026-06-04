{
    fetchFromGitHub,
    lib,
    rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
    pname = "illuminanced";
    version = "1.0.2";

    src = fetchFromGitHub {
        owner = "mikhail-m1";
        repo = "illuminanced";
        tag = finalAttrs.version;
        hash = "sha256-ZEVma0uj9rsWB+vfUL7w3dHxI/ppBCG23TirGE+RREk=";
    };

    cargoHash = "sha256-kPWoQ6rE4wBjmqQLNPY4UWJt/AOgr+eVKY0ZK7B4K1A=";

    meta = {
        description = "Ambient Light Sensor Daemon for Linux";
        homepage = "https://github.com/mikhail-m1/illuminanced";
        license = lib.licenses.gpl3Only;
        mainProgram = "illuminanced";
    };
})
