{
    lib,
    stdenv,
    fetchFromGitHub,
    callPackage,
    makeWrapper,
    makeDesktopItem,
    copyDesktopItems,
    python3Packages,
    qt6,
    bash,
    cabextract,
    coreutils,
    curl,
    findutils,
    gnugrep,
    gnused,
    gzip,
    p7zip,
    procps,
    protontricks,
    steam-run,
    unzip,
    wget,
    wineWow64Packages,
    winetricks,
    xdg-utils,
    xz,
}:

let
    jackifyEngine = callPackage ./engine.nix { };

    pythonInputs = with python3Packages; [
        packaging
        psutil
        pycryptodomex
        pyside6
        pyyaml
        requests
        tqdm
        vdf
        watchdog
    ];

    runtimePath = lib.makeBinPath [
        bash
        cabextract
        coreutils
        curl
        findutils
        gnugrep
        gnused
        gzip
        p7zip
        procps
        protontricks
        steam-run
        unzip
        wget
        wineWow64Packages.stable
        winetricks
        xdg-utils
        xz
    ];
in
stdenv.mkDerivation (finalAttrs: {
    pname = "jackify";
    version = "0.7.1.1";

    src = fetchFromGitHub {
        owner = "Omni-guides";
        repo = "Jackify";
        rev = "b72b3daa3074be3b192425e07bb6df8d44557a26";
        hash = "sha256-d45kl4bB8+PaES8SlnhBJqO9nvqqB9xzj1w/WA9YtwY=";
    };

    nativeBuildInputs = [
        copyDesktopItems
        makeWrapper
        qt6.wrapQtAppsHook
    ];

    buildInputs = [
        qt6.qtbase
    ]
    ++ pythonInputs;

    dontBuild = true;

    postPatch = ''
        substituteInPlace jackify/backend/handlers/wine_wrapper.py \
            --replace-fail \
                'exec "''${PROTON_DIST_PATH}/bin/''${BINARY_NAME}" "$@"' \
                'exec "${steam-run}/bin/steam-run" "''${PROTON_DIST_PATH}/bin/''${BINARY_NAME}" "$@"'
    '';

    desktopItems = [
        (makeDesktopItem {
            name = "jackify";
            desktopName = "Jackify";
            comment = "Linux Wabbajack modlist manager";
            exec = "jackify %u";
            icon = "jackify";
            categories = [ "Game" ];
            mimeTypes = [
                "x-scheme-handler/jackify"
                "x-scheme-handler/nxm"
            ];
        })
    ];

    installPhase = ''
        runHook preInstall

        appDir="$out/share/jackify"
        mkdir -p "$appDir" "$out/bin" "$out/share/icons/hicolor/256x256/apps"

        cp -r jackify assets binaries files manifests "$appDir"/
        cp CHANGELOG.md LICENSE README.md requirements.txt "$appDir"/

        install -Dm644 assets/JackifyLogo_256.png \
            "$out/share/icons/hicolor/256x256/apps/jackify.png"

        install -Dm755 ${jackifyEngine}/bin/jackify-engine \
            "$appDir/jackify/engine/jackify-engine"

        makeWrapper ${python3Packages.python.interpreter} "$out/bin/jackify" \
            --add-flags "-m jackify" \
            --chdir "$appDir" \
            --set JACKIFY_ENGINE_PATH "$appDir/jackify/engine/jackify-engine" \
            --prefix PYTHONPATH : "$appDir:${python3Packages.makePythonPath pythonInputs}" \
            --prefix PATH : "${runtimePath}"

        runHook postInstall
    '';

    postFixup = ''
        wrapQtApp "$out/bin/jackify"
    '';

    passthru = {
        inherit jackifyEngine;
        fetch-engine-deps = jackifyEngine.fetch-deps;
    };

    meta = {
        description = "Linux application for installing and configuring Wabbajack modlists";
        homepage = "https://github.com/Omni-guides/Jackify";
        license = lib.licenses.gpl3Only;
        mainProgram = "jackify";
        platforms = lib.platforms.linux;
    };
})
