{
    lib,
    stdenv,
    fetchFromGitHub,
    cmake,
}:

stdenv.mkDerivation {
    pname = "libwinpath";
    version = "unstable-2024-12-07";

    src = fetchFromGitHub {
        owner = "qsniyg";
        repo = "libwinpath";
        rev = "28a2e33c580ec6f4c4dadf8f74b64012800f284f";
        hash = "sha256-qKpaSa8ZvNTodaJuhP5V9n3n3FbvwLlwYCbXC3ftJEI=";
    };

    nativeBuildInputs = [ cmake ];

    meta = {
        description = "Library for Unices to interact with Windows case-insensitive paths";
        homepage = "https://github.com/qsniyg/libwinpath";
        license = lib.licenses.lgpl3;
        mainProgram = "libwinpath";
    };
}
