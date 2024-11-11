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
        rev = "bf5dc85af5ac51d85f36b393eb03ea0a855cfde5";
        hash = "sha256-clEInCKrARoM66mbz0ROXBHfX4CGHPji9o2N3nLHw7A=";
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
