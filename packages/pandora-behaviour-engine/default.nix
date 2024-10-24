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
        rev = "bc403bda71a7c47181fcf2732e627017f5bbff4f";
        hash = "sha256-/x4fp2phhoDqxC+Ck3IqVLIueJl1350gbU9HEhIa4qM=";
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
