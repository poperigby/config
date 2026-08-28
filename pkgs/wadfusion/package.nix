{
    lib,
    stdenvNoCC,
    fetchFromGitHub,
    makeWrapper,
    python3,
}:

stdenvNoCC.mkDerivation {
    pname = "wadfusion";
    version = "1.6.1-unstable-2026-08-27";

    src = fetchFromGitHub {
        owner = "Owlet7";
        repo = "wadfusion";
        rev = "02a2511e9bb2dd086092c30eb10405498ead248b";
        hash = "sha256-pgz2OupiG8O1uqIelSujoR+0h4CytC91VrxfV9AaGLk=";
    };

    nativeBuildInputs = [
        makeWrapper
    ];

    installPhase = ''
        runHook preInstall

        appDir="$out/share/wadfusion"
        mkdir -p "$appDir" "$out/bin"

        cp -r data licenses omg res source_wads ultrawiderpix wadfusion.py "$appDir"/

        makeWrapper ${lib.getExe python3} "$out/bin/wadfusion" \
            --add-flags "$appDir/wadfusion.py"

        runHook postInstall
    '';

    meta = {
        description = "Simple IWAD merge utility";
        homepage = "https://github.com/Owlet7/wadfusion";
        license = lib.licenses.gpl3Plus;
        mainProgram = "wadfusion";
        platforms = lib.platforms.all;
    };
}
