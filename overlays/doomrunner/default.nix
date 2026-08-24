final: prev: {
    doomrunner = prev.doomrunner.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
            ./no-auto-engine-picker.patch
        ];

        qtWrapperArgs = (old.qtWrapperArgs or [ ]) ++ [
            "--set-default QT_QPA_PLATFORMTHEME xdgdesktopportal"
        ];
    });
}
