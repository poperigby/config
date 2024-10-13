{
    fetchFromGitHub,
    lib,
    rustPlatform,
}:

rustPlatform.buildRustPackage {
    pname = "illuminanced";
    version = "unstable-2024-08-13";

    src = fetchFromGitHub {
        owner = "mikhail-m1";
        repo = "illuminanced";
        rev = "f61d87e0543174cc8e62347ac4326d145879fe1a";
        hash = "sha256-0rG6Br/S7M28e1EGub8gSoEalfUm+3e9b4NyRjOZlt4=";
    };

    cargoLock = {
        lockFile = ./Cargo.lock;
    };

    postPatch = ''
        ln -s ${./Cargo.lock} Cargo.lock
    '';

    meta = {
        description = "Ambient Light Sensor Daemon for Linux";
        homepage = "https://github.com/mikhail-m1/illuminanced";
        license = lib.licenses.gpl3Only;
        mainProgram = "illuminanced";
    };
}
