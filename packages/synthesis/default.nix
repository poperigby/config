{
    buildDotnetModule,
    dotnetCorePackages,
    fetchFromGitHub,
    git,
    lib,
}:

buildDotnetModule rec {
    pname = "synthesis";
    version = "0.31-pr001";

    src = fetchFromGitHub {
        owner = "Mutagen-Modding";
        repo = "Synthesis";
        rev = "7662db46944855d1166e04f9b5b14ca2ec7622d8";
        hash = "sha256-LsJdN0FAtuT1ErSX1S6NCuZCRnKd0ZZptISf6B5g2/Y=";
        leaveDotGit = true;
    };

    projectFile = "Synthesis.Bethesda.CLI/Synthesis.Bethesda.CLI.csproj";
    dotnet-sdk = dotnetCorePackages.sdk_8_0;
    dotnet-runtime = dotnetCorePackages.runtime_8_0;
    nugetDeps = ./deps.nix;

    propagatedBuildInputs = [ git ];

    postFixup = ''
        mv $out/bin/Synthesis.Bethesda.CLI $out/bin/synthesis
    '';

    meta = {
        description = "A patcher pipeline framework and GUI.  Run collections of code-based mods to create content customized for your load order";
        homepage = "https://github.com/Mutagen-Modding/Synthesis";
        license = lib.licenses.gpl3Only;
        mainProgram = pname;
        platforms = lib.platforms.all;
    };
}
