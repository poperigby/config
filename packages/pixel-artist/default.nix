{
    fetchFromGitHub,
    lib,
    python3Packages,
}:

python3Packages.buildPythonApplication rec {
    pname = "pixel-artist";
    version = "0.0.6";

    src = fetchFromGitHub {
        owner = "alexpnt";
        repo = pname;
        rev = "v${version}";
        hash = "sha256-+bQNBMugNisEqBIPSEQd+RlJcgb/AkqeaKe+07dUYCI=";
    };

    propagatedBuildInputs = with python3Packages; [
        colormath
        pillow
    ];

    doCheck = false;

    meta = with lib; {
        description = "Command line tool to pixelate images with customizable granularity and different color palletes";
        homepage = "https://github.com/alexpnt/pixel-artist/tree/master";
        license = licenses.mit;
        mainProgram = pname;
    };
}

