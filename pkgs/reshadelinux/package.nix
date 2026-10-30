{
    lib,
    stdenvNoCC,
    fetchFromGitHub,
    makeWrapper,
    bashInteractive,
    coreutils,
    curl,
    file,
    findutils,
    git,
    gnugrep,
    gnused,
    libnotify,
    p7zip,
    python3,
    yad,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "reshadelinux";
    version = "1.4.1";

    src = fetchFromGitHub {
        owner = "asafelobotomy";
        repo = "reshadelinux";
        tag = "v${finalAttrs.version}";
        hash = "sha256-2+ZcKx22LfjfkF5VAw9XTjCok88uD70KsJGP6k6dI9Y=";
    };

    nativeBuildInputs = [
        makeWrapper
    ];

    # The scripts call compgen, which only bashInteractive provides; patchShebangs resolves bash from buildInputs.
    buildInputs = [
        bashInteractive
    ];

    installPhase = ''
        runHook preInstall

        appDir="$out/share/reshadelinux"
        appImageDir=packaging/appimage/AppDir
        mkdir -p "$appDir" "$out/bin"

        cp -r lib reshadelinux.sh reshadelinux-gui.sh VERSION "$appDir"/

        # The GUI launcher picks yad when it is on PATH and forwards any arguments to the CLI.
        makeWrapper "$appDir/reshadelinux-gui.sh" "$out/bin/reshadelinux" \
            --prefix PATH : ${
                lib.makeBinPath [
                    coreutils
                    curl
                    file
                    findutils
                    git
                    gnugrep
                    gnused
                    libnotify
                    p7zip
                    python3
                    yad
                ]
            } \
            --set-default RESHADE_ADDON_SUPPORT 1

        install -Dm644 "$appImageDir/io.github.asafelobotomy.reshadelinux.desktop" \
            "$out/share/applications/io.github.asafelobotomy.reshadelinux.desktop"
        substituteInPlace "$out/share/applications/io.github.asafelobotomy.reshadelinux.desktop" \
            --replace-fail "Exec=reshadelinux-gui.sh" "Exec=reshadelinux"
        install -Dm644 "$appImageDir/reshadelinux.png" "$out/share/pixmaps/reshadelinux.png"

        runHook postInstall
    '';

    meta = {
        description = "Install the official ReShade runtime for Wine and Proton games";
        homepage = "https://github.com/asafelobotomy/reshadelinux";
        license = lib.licenses.gpl2Plus;
        mainProgram = "reshadelinux";
        platforms = lib.platforms.linux;
    };
})
