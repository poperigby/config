{
    lib,
    stdenv,
    fetchFromGitHub,
    nix-update-script,
    makeWrapper,
    makeFontsConf,
    runCommand,
    python3,
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
    customtkinter' = python3.pkgs.customtkinter.overridePythonAttrs (old: {
        postPatch = (old.postPatch or "") + ''
            substituteInPlace customtkinter/windows/widgets/font/font_manager.py \
                --replace-fail \
                    'shutil.copy(font_path, os.path.expanduser(cls.linux_font_path))' \
                    'pass'
        '';
    });

    customtkinterFonts = runCommand "customtkinter-fonts" { } ''
        fonts=${customtkinter'}/${python3.sitePackages}/customtkinter/assets/fonts
        mkdir -p "$out/share/fonts/truetype"
        cp "$fonts/Roboto/"*.ttf "$out/share/fonts/truetype/"
        cp "$fonts/CustomTkinter_shapes_font.otf" "$out/share/fonts/truetype/"
    '';

    fontsConf = makeFontsConf {
        fontDirectories = [ customtkinterFonts ];
    };

    python = python3.withPackages (
        ps: with ps; [
            customtkinter'
            py7zr
            ps."libarchive-c"
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
        ]
    );
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

    nativeBuildInputs = [ makeWrapper ];

    dontBuild = true;

    installPhase = ''
        runHook preInstall

        appDir="$out/share/amethyst-mod-manager"
        mkdir -p "$appDir" "$out/bin" "$out/share/applications" \
            "$out/share/icons/hicolor/256x256/apps"

        cp -r src/. "$appDir/"
        cp Changelog.txt "$appDir/"

        cat > "$out/bin/amethyst-mod-manager" <<EOF
        #!${stdenv.shell}
        export MOD_MANAGER_PROFILES_DIR="\''${XDG_CONFIG_HOME:-\$HOME/.config}/AmethystModManager/Profiles"
        mkdir -p "\$MOD_MANAGER_PROFILES_DIR"

        case "\''${1:-}" in
            deploy|restore|list-games|list-profiles|clear-credentials)
                exec ${python}/bin/python "$appDir/cli.py" "\$@"
                ;;
            *)
                exec ${python}/bin/python "$appDir/gui.py" "\$@"
                ;;
        esac
        EOF
        chmod +x "$out/bin/amethyst-mod-manager"

        wrapProgram $out/bin/amethyst-mod-manager \
            --set FONTCONFIG_FILE ${fontsConf} \
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

        substitute src/appimage/mod-manager.desktop \
            "$out/share/applications/amethyst-mod-manager.desktop" \
            --replace-fail "Exec=mod-manager" "Exec=amethyst-mod-manager" \
            --replace-fail "Icon=mod-manager" "Icon=amethyst-mod-manager"

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
