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
        rev = "837207ded2e19a880767f7f566acfc66a382651d";
        hash = "sha256-GS8i+O9ysq7J/Zwt1Vtj0IV4TL992Xc6lWDZoTIhPrM=";
        leaveDotGit = true;
    };

    projectFile = "Synthesis.Bethesda.CLI/Synthesis.Bethesda.CLI.csproj";
    dotnet-sdk = dotnetCorePackages.sdk_8_0;
    # Required for Synthesis to find the SDK
    dotnet-runtime = dotnetCorePackages.sdk_8_0;
    nugetDeps = ./deps.nix;

    nativeBuildInputs = [ git ];

    postFixup = ''
        mv $out/bin/Synthesis.Bethesda.CLI $out/bin/${pname}
    '';

    meta = {
        description = "Patcher pipeline framework and GUI.  Run collections of code-based mods to create content customized for your load order";
        homepage = "https://github.com/Mutagen-Modding/Synthesis";
        license = lib.licenses.gpl3Only;
        mainProgram = pname;
        platforms = lib.platforms.all;
    };
}
