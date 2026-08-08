final: prev: {
    openmw = prev.openmw.overrideAttrs (old: {
        src = prev.fetchFromGitLab {
            owner = "OpenMW";
            repo = "openmw";
            rev = "master";
            hash = "sha256-9rptPfJbj9fcPaZADkKbzKwuXpz8dLElQP1J3Fqy2y0=";
        };
    });
}
