{
    buildDotnetModule,
    dotnetCorePackages,
    fetchFromGitHub,
    git,
    lib,
}:

buildDotnetModule rec {
    pname = "synthesis";
    version = "0.30.6";

    src = fetchFromGitHub {
        owner = "Mutagen-Modding";
        repo = "Synthesis";
        rev = version;
        hash = "sha256-6LKapTIKnZMbJtKEUOx64iitznRYmC4QOhLFW/qsKBo=";
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
