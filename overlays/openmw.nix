final: prev: {
    openmw = prev.openmw.overrideAttrs (old: {
        src = prev.fetchFromGitLab {
            owner = "OpenMW";
            repo = "openmw";
            rev = "b1612f97357616f578fa66cbf3e97b9b50349c7d";
            hash = "sha256-Ra6jhfw/yw1xPgRviQ9NMSj14/JZvG3U38624gJcMFg=";
        };

        nativeBuildInputs = old.nativeBuildInputs ++ [ prev.makeWrapper ];

        postFixup = (old.postFixup or "") + ''
            mv $out/bin/${old.pname} $out/bin/.${old.pname}-launch-target

            # Improve OpenMW performance on AMD systems
            # https://modding-openmw.com/tips/performance/#os-gpu-specific-tips
            makeWrapper ${prev.mangohud}/bin/mangohud $out/bin/${old.pname} \
                --add-flags "--dlsym" \
                --add-flags "$out/bin/.${old.pname}-launch-target" \
                --set OSG_VERTEX_BUFFER_HINT "VERTEX_BUFFER_OBJECT"
        '';
    });
}
