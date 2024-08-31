{
    cmake,
    fetchFromGitHub,
    ninja,
    stdenv,
}:

stdenv.mkDerivation rec {
    pname = "tacent";
    version = "0.8.17";

    src = fetchFromGitHub {
        owner = "bluescan";
        repo = pname;
        rev = "3694dff1ad3659f9f0eaea3c145539cda63440e6";
        hash = "sha256-0An8sDTCW8PkK1chvt/ASrx/8ykVZiaqdm+ylU/gRdQ=";
    };

    nativeBuildInputs = [
        cmake
        ninja
    ];
}
