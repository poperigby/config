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
        rev = "828cca46ab05727defafe24239750de52c3249e8";
        hash = "sha256-iSemGYfAG+nE0byz2N7iuwX4yHpXGSRzTtNgb+Bbs54=";
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
