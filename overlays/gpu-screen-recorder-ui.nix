final: prev: {
    gpu-screen-recorder-ui = prev.gpu-screen-recorder-ui.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
            rm -f "$out/share/applications/gpu-screen-recorder.desktop"
        '';
    });
}
