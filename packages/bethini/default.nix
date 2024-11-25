{
    fetchFromGitHub,
    inputs,
    lib,
    python3Packages,
    system,
}:

python3Packages.buildPythonPackage rec {
    pname = "bethini";
    version = "unstable-2024-10-03";

    src = fetchFromGitHub {
        owner = "DoubleYouC";
        repo = "Bethini-Pie-Performance-INI-Editor";
        rev = "19fd096558243de7044e7cf965aca20892db2f3e";
        hash = "sha256-WM86r2/6KiKvoMMDJWneHm/qkZ/omazQ7oR03MNscSU=";
        fetchSubmodules = true;
    };

    propagatedBuildInputs = with python3Packages; [
       pillow
       simpleeval
       # inputs.ttkbootstrap.legacyPackages.${system}.python3Packages.ttkbootstrap
    ];

    meta = {
        description = "Bethini Pie is an INI editor designed to allow advanced customization of game configuration settings";
        homepage = "https://github.com/DoubleYouC/Bethini-Pie-Performance-INI-Editor";
        changelog = "https://github.com/DoubleYouC/Bethini-Pie-Performance-INI-Editor/blob/${src.rev}/changelog.txt";
        license = lib.licenses.cc-by-nc-sa-40;
        mainProgram = "bethini-pie";
        platforms = lib.platforms.all;
    };
}
