{
    cmake,
    fetchFromGitHub,
    ninja,
    stdenv,
}:

stdenv.mkDerivation rec {
    pname = "tacent";
    version = "0.8.18";

    src = fetchFromGitHub {
        owner = "bluescan";
        repo = pname;
        rev = version;
        hash = "sha256-z8VuJS8OaVw5CeO/udvBEmcURKIy1oWVYUv6Ai8lTI8=";
    };

    nativeBuildInputs = [
        cmake
        ninja
    ];
}
