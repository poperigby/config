{
    lib,
    stdenv,
    fetchFromGitHub,
    nix-update-script,
    makeWrapper,
    makeFontsConf,
    makeDesktopItem,
    copyDesktopItems,
    python3Packages,
    gtk3,
    libarchive,
    p7zip,
    unrar,
    xdg-utils,
    zenity,
    protontricks,
    cabextract,
}:

let
    customtkinter = python3Packages.customtkinter.overridePythonAttrs (old: {
        postPatch = (old.postPatch or "") + ''
            substituteInPlace customtkinter/windows/widgets/font/font_manager.py \
                --replace-fail \
                    'shutil.copy(font_path, os.path.expanduser(cls.linux_font_path))' \
                    'pass'
        '';
    });

    fontsConf = makeFontsConf {
        fontDirectories = [
            "${customtkinter}/${python3Packages.python.sitePackages}/customtkinter/assets/fonts"
        ];
    };

    pythonInputs = with python3Packages; [
        customtkinter
        py7zr
        python3Packages."libarchive-c"
        pillow
        lz4
        zstandard
        requests
        websocket-client
        keyring
        jeepney
        importlib-metadata
        backports-tarfile
        msgpack
        bsdiff4
        pygobject3
        tkinter
    ];
in
stdenv.mkDerivation (finalAttrs: {
    pname = "amethyst-mod-manager";
    version = "1.3.8";

    src = fetchFromGitHub {
        owner = "ChrisDKN";
        repo = "Amethyst-Mod-Manager";
        tag = "v${finalAttrs.version}";
        hash = "sha256-mRscWjvLOKF/A0ldRn8VAQIUdqywBTfjp2P6bVvkzUg=";
    };

    nativeBuildInputs = [
        copyDesktopItems
        makeWrapper
    ];

    buildInputs = [
        gtk3
    ]
    ++ pythonInputs;

    desktopItems = [
        (makeDesktopItem {
            name = "amethyst-mod-manager";
            desktopName = "Amethyst Mod Manager";
            comment = "Game mod manager for Linux";
            exec = "amethyst-mod-manager --nxm %u";
            icon = "amethyst-mod-manager";
            categories = [ "Game" ];
            mimeTypes = [ "x-scheme-handler/nxm" ];
            startupWMClass = "mod-manager";
        })
    ];

    dontBuild = true;

    installPhase = ''
        runHook preInstall

        appDir="$out/share/amethyst-mod-manager"
        mkdir -p "$appDir" "$out/bin" "$out/share/applications" \
            "$out/share/icons/hicolor/256x256/apps"

        cp -r src/. "$appDir/"
        cp Changelog.txt "$appDir/"

        substituteInPlace "$appDir/Nexus/nxm_handler.py" \
            --replace-fail \
                "return f'{cls._quote_if_needed(exe)} {cls._quote_if_needed(script)} --nxm %u'" \
                "return '$out/bin/amethyst-mod-manager --nxm %u'"

        cat > "$out/bin/amethyst-mod-manager" <<EOF
        #!${stdenv.shell}
        export MOD_MANAGER_PROFILES_DIR="\''${XDG_CONFIG_HOME:-\$HOME/.config}/AmethystModManager/Profiles"
        mkdir -p "\$MOD_MANAGER_PROFILES_DIR"

        case "\''${1:-}" in
            deploy|restore|list-games|list-profiles|clear-credentials)
                exec ${python3Packages.python.interpreter} "$appDir/cli.py" "\$@"
                ;;
            *)
                exec ${python3Packages.python.interpreter} "$appDir/gui.py" "\$@"
                ;;
        esac
        EOF
        chmod +x "$out/bin/amethyst-mod-manager"

        wrapProgram $out/bin/amethyst-mod-manager \
            --set FONTCONFIG_FILE ${fontsConf} \
            --prefix PYTHONPATH : ${python3Packages.makePythonPath pythonInputs} \
            --prefix PATH : ${
                lib.makeBinPath [
                    p7zip
                    libarchive
                    unrar
                    xdg-utils
                    zenity
                    protontricks
                    cabextract
                ]
            } \
            --prefix LD_LIBRARY_PATH : ${
                lib.makeLibraryPath [
                    gtk3
                    libarchive
                ]
            }

        install -Dm644 src/appimage/mod-manager.png \
            "$out/share/icons/hicolor/256x256/apps/amethyst-mod-manager.png"

        runHook postInstall
    '';

    passthru.updateScript = nix-update-script { };

    meta = {
        description = "Linux-native mod manager for a variety of games";
        homepage = "https://github.com/ChrisDKN/Amethyst-Mod-Manager";
        changelog = "https://github.com/ChrisDKN/Amethyst-Mod-Manager/blob/${finalAttrs.src.rev}/Changelog.txt";
        license = lib.licenses.gpl3Only;
        maintainers = with lib.maintainers; [ PopeRigby ];
        mainProgram = "amethyst-mod-manager";
        platforms = lib.platforms.linux;
    };
})
