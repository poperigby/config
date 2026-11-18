{
    lib,
    stdenvNoCC,
    fetchzip,
    bash,
    callPackage,
    coreutils,
    copyDesktopItems,
    curl,
    icoutils,
    inputs,
    jq,
    makeDesktopItem,
    nix-update,
    util-linux,
    wineWow64Packages,
    writeShellApplication,
}:

let
    runtime = callPackage ./runtime.nix {
        inherit inputs;
        wine = wineWow64Packages.stable;
    };
    fetchWcc = callPackage ./fetch-wcc.nix { };
in
stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "wolvenkit";
    version = "7.2.0-nightly.2026-10-24";

    src = fetchzip {
        url = "https://github.com/WolvenKit/WolvenKit-7-nightly/releases/download/${finalAttrs.version}/WolvenKit-${finalAttrs.version}.zip";
        hash = "sha256-enY6s+RUZDELYO3l9y+Ow0/qy1v2mtFkREpFWMLdSvE=";
        stripRoot = false;
    };

    nativeBuildInputs = [
        copyDesktopItems
        icoutils
    ];

    desktopItems = [
        (makeDesktopItem {
            name = "wolvenkit";
            desktopName = "WolvenKit 7";
            comment = "Modding tool for The Witcher 3";
            exec = "wolvenkit";
            icon = "wolvenkit";
            categories = [
                "Development"
                "Game"
            ];
        })
    ];

    installPhase = ''
        runHook preInstall

        appDir="$out/share/wolvenkit/app"
        mkdir -p "$appDir"
        cp -r . "$appDir"

        installWrapper() {
            substitute ${./wrapper.sh} "$out/bin/$1" \
                --subst-var-by bash ${lib.getExe bash} \
                --subst-var-by path ${
                    lib.makeBinPath [
                        coreutils
                        util-linux
                    ]
                } \
                --subst-var-by app "$appDir" \
                --subst-var-by launcher ${runtime}/bin/.launcher \
                --subst-var-by exe "$2"
            chmod +x "$out/bin/$1"
        }
        mkdir -p "$out/bin"
        installWrapper wolvenkit WolvenKit.exe
        installWrapper wolvenkit-cli WolvenKit.CLI.exe
        ln -s ${lib.getExe fetchWcc} "$out/bin/wolvenkit-fetch-wcc"

        wrestool -x -t 14 WolvenKit.exe -o wolvenkit.ico
        icotool -x -w 512 wolvenkit.ico -o wolvenkit.png
        install -Dm644 wolvenkit.png "$out/share/icons/hicolor/512x512/apps/wolvenkit.png"

        runHook postInstall
    '';

    passthru = {
        inherit runtime;

        # Release tags carry the nightly date, so the update follows the latest release tag.
        updateScript = writeShellApplication {
            name = "wolvenkit-update";
            runtimeInputs = [
                curl
                jq
                nix-update
            ];
            text = ''
                tag=$(curl -fsSL https://api.github.com/repos/WolvenKit/WolvenKit-7-nightly/releases/latest | jq -r .tag_name)
                exec nix-update --flake --version "$tag" wolvenkit "$@"
            '';
        };
    };

    meta = {
        description = "Modding tool for The Witcher 3, run through Wine";
        homepage = "https://github.com/WolvenKit/WolvenKit-7-nightly";
        license = lib.licenses.gpl3Only;
        sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
        mainProgram = "wolvenkit";
        platforms = [ "x86_64-linux" ];
    };
})
