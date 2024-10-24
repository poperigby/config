{
    buildDotnetModule,
    dotnetCorePackages,
    fetchFromGitHub,
    lib,
}:

buildDotnetModule {
    pname = "pandora-behaviour-engine";
    version = "2.3.5-beta";

    src = fetchFromGitHub {
        owner = "poperigby";
        repo = "Pandora-Behaviour-Engine-Plus";
        rev = "e6838c370ad7dbbcbb1760eae316928ffd19e0ed";
        hash = "sha256-kaXGLboQrfmc3rEjbd5puEHAEo7pTAV0+oNGlscdKWQ=";
        fetchSubmodules = true;
    };

    projectFile = "Pandora+.sln";
    dotnet-sdk = dotnetCorePackages.sdk_8_0;
    dotnet-runtime = dotnetCorePackages.runtime_8_0;
    nugetDeps = ./deps.nix;

    meta = {
        description = "Patcher for behavior, character, and skeleton project files for Skyrim Special Edition";
        homepage = "https://github.com/poperigby/Pandora-Behaviour-Engine-Plus";
        mainProgram = "Pandora Behaviour Engine+";
        license = lib.licenses.gpl3;
        platforms = lib.platforms.all;
    };
}
