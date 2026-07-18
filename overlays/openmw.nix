final: prev: {
    openmw = prev.openmw.overrideAttrs (old: {
        src = prev.fetchFromGitLab {
            owner = "OpenMW";
            repo = "openmw";
            rev = "master";
            hash = "sha256-88t1iHErfc5hrU09ym+m/b7awL3Ljp+q7F0SKTHaaYc=";
        };
    });
}
