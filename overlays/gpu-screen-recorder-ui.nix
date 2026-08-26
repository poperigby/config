final: prev: {
    gpu-screen-recorder-ui = prev.gpu-screen-recorder-ui.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
            substituteInPlace tools/gsr-game-tracker/native_games.c \
                --replace-fail '"gzdoom", "taisei"' '"gzdoom", "uzdoom", "taisei"'
        '';

        postInstall = (old.postInstall or "") + ''
            rm -f "$out/share/applications/gpu-screen-recorder.desktop"
        '';
    });
}
