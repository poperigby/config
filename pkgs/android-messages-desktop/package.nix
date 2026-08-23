{
    lib,
    stdenvNoCC,
    fetchFromGitHub,
    fetchPnpmDeps,
    makeDesktopItem,
    makeWrapper,
    copyDesktopItems,
    nodejs,
    pnpm,
    pnpmConfigHook,
    pnpmBuildHook,
    electron_41,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "android-messages-desktop";
    version = "6.1.0";

    src = fetchFromGitHub {
        owner = "OrangeDrangon";
        repo = "android-messages-desktop";
        tag = "v${finalAttrs.version}";
        hash = "sha256-+jF5GsVoCgjx0AyUycI+m0pM867ygMVOfKRn3Ro5lRw=";
    };

    pnpmDeps = fetchPnpmDeps {
        inherit (finalAttrs) pname version src;
        fetcherVersion = 4;
        hash = "sha256-dCcbXR/5fljqdSMhKn9YWd5r26ihL7Ey8yUY6K8YmyI=";
    };

    nativeBuildInputs = [
        nodejs
        pnpm
        pnpmConfigHook
        pnpmBuildHook
        makeWrapper
        copyDesktopItems
    ];

    strictDeps = true;
    env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

    postBuild = ''
        pnpm prune --prod
    '';

    installPhase = ''
        runHook preInstall

        appDir="$out/share/android-messages-desktop"
        mkdir -p "$appDir" "$out/bin" "$out/share/icons/hicolor/256x256/apps"

        cp -r app node_modules package.json resources "$appDir"/
        install -Dm644 assets/android_messages_desktop_icon.png \
            "$out/share/icons/hicolor/256x256/apps/pw.kmr.amd.png"
        ln -s pw.kmr.amd.png \
            "$out/share/icons/hicolor/256x256/apps/android-messages-desktop.png"

        makeWrapper ${lib.getExe electron_41} "$out/bin/android-messages-desktop" \
            --add-flags "$appDir" \
            --set ELECTRON_IS_DEV 0

        runHook postInstall
    '';

    desktopItems = [
        (makeDesktopItem {
            name = "pw.kmr.amd";
            desktopName = "Android Messages Desktop";
            exec = "android-messages-desktop %U";
            icon = "pw.kmr.amd";
            comment = "Messages for web, as a desktop app";
            categories = [
                "Network"
                "InstantMessaging"
            ];
            startupWMClass = "pw.kmr.amd";
        })
    ];

    meta = {
        description = "Messages for web, as a desktop app";
        homepage = "https://github.com/OrangeDrangon/android-messages-desktop";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ PopeRigby ];
        mainProgram = "android-messages-desktop";
        platforms = lib.platforms.linux;
    };
})
