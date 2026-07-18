final: prev: {
    openmw = prev.openmw.overrideAttrs (old: {
        src = prev.fetchFromGitLab {
            owner = "OpenMW";
            repo = "openmw";
            rev = "master";
            hash = "sha256-CfqeA+SGtOkSp0nOtSjVjlSLEpeyJxB9ugpye7MDkkk=";
        };
    });
}
