final: prev: {
    doomrunner = prev.doomrunner.overrideAttrs (old: {
        qtWrapperArgs = (old.qtWrapperArgs or [ ]) ++ [
            "--set-default QT_QPA_PLATFORMTHEME xdgdesktopportal"
        ];

        postPatch = (old.postPatch or "") + ''
            substituteInPlace Sources/Dialogs/OwnFileDialog.cpp \
                --replace-fail \
                    'os::getLinuxDesktopEnv() == "KDE" ? QFileDialog::Options() : QFileDialog::Option::DontUseNativeDialog' \
                    'QFileDialog::Options()'
        '';
    });
}
