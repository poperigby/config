{
    lib,
    fetchFromGitHub,
    dotnetCorePackages,
    git,
}:

dotnetCorePackages.buildDotnetModule rec {
    pname = "jackify-engine";
    version = "0.5.7";

    src = fetchFromGitHub {
        owner = "Omni-guides";
        repo = "dev-jackify-engine";
        rev = "a381f57e3aba07f5a0b21d5d28bbf7fe4e86f0f1";
        hash = "sha256-xCpa3eDqJk7f4dRVrtS2JsgGjjMJ9w/UhxIhzWduwOc=";
    };

    projectFile = "jackify-engine/jackify-engine.csproj";
    nugetDeps = ./engine-deps.json;

    postPatch = ''
        rm global.json
        sed -i '/PackageReference Include="GitInfo"/,/<\/PackageReference>/d' \
            Wabbajack.Services.OSIntegrated/Wabbajack.Services.OSIntegrated.csproj
        sed -i \
            -e 's/var version =/var version = "${version}";/' \
            -e '/ThisAssembly.Git.SemVer/d' \
            -e 's/ApplicationSha = ThisAssembly.Git.Sha,/ApplicationSha = "${src.rev}",/' \
            Wabbajack.Services.OSIntegrated/ServiceExtensions.cs
    '';

    dotnet-sdk = dotnetCorePackages.sdk_8_0;
    dotnet-runtime = dotnetCorePackages.runtime_8_0;
    nativeBuildInputs = [ git ];

    selfContainedBuild = true;
    runtimeId = "linux-x64";
    executables = [ "jackify-engine" ];

    meta = {
        description = "Linux-native Wabbajack install engine used by Jackify";
        homepage = "https://github.com/Omni-guides/dev-jackify-engine";
        license = lib.licenses.gpl3Only;
        mainProgram = "jackify-engine";
        platforms = [ "x86_64-linux" ];
    };
}
