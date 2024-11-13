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
        rev = "781f9deb4fd92d838c9663e1a85ca7fe4b68e762";
        hash = "sha256-FsCAZyROChS8rbt/fPNMYxYPQerCzqlGF3+uwk41u8k=";
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
