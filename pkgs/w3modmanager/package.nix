{
    _7zz,
    copyDesktopItems,
    desktop-file-utils,
    lib,
    makeDesktopItem,
    makeWrapper,
    python3,
    qt6,
    stdenv,
    unrar,
    xdg-user-dirs,
    xdg-utils,
}:

let
    python = python3.withPackages (ps: [ ps.pyqt6 ]);
in
stdenv.mkDerivation {
    pname = "w3modmanager";
    version = "0.41b";

    src = fetchGit {
        url = "ssh://git@github.com/poperigby/w3modmanager.git";
        rev = "f4bae3b467c97667f7ac442a597246a04578d12f";
    };

    dontBuild = true;

    nativeBuildInputs = [
        makeWrapper
        copyDesktopItems
        qt6.wrapQtAppsHook
    ];
    buildInputs = [ qt6.qtbase ];
    dontWrapQtApps = true;

    desktopItems = [
        (makeDesktopItem {
            name = "w3modmanager";
            desktopName = "W3 Mod Manager";
            comment = "Manage The Witcher 3 mods";
            exec = "w3modmanager";
            icon = "applications-games";
            categories = [ "Game" ];
        })
    ];

    installPhase = ''
        runHook preInstall

        install -Dm644 w3modmanager.py "$out/share/w3modmanager/w3modmanager.py"
        substituteInPlace "$out/share/w3modmanager/w3modmanager.py" \
            --replace-fail \
                'f"Exec={shlex.quote(sys.executable)} {shlex.quote(str(script))} %u"' \
                '"Exec=@out@/bin/w3modmanager %u"'
        substituteInPlace "$out/share/w3modmanager/w3modmanager.py" --replace-fail '@out@' "$out"

        makeWrapper ${python}/bin/python "$out/bin/w3modmanager" \
            --add-flags "$out/share/w3modmanager/w3modmanager.py" \
            --prefix PATH : ${
                lib.makeBinPath [
                    _7zz
                    desktop-file-utils
                    unrar
                    xdg-user-dirs
                    xdg-utils
                ]
            } \
            "''${qtWrapperArgs[@]}"

        runHook postInstall
    '';

    meta = {
        description = "Witcher 3 mod manager for Linux";
        homepage = "https://github.com/poperigby/w3modmanager";
        mainProgram = "w3modmanager";
        platforms = lib.platforms.linux;
    };
}
