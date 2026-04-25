final: prev: {
    openmw = prev.openmw.overrideAttrs (old: {
        src = prev.fetchFromGitLab {
            owner = "OpenMW";
            repo = "openmw";
            rev = "6226836c39fc0082eba6893e180b891e445afed6";
            hash = "sha256-YHkzsWdlLyMdAJhbe+zxJHcUXGm1EVi24XsP1t106rk=";
        };
    });
}
