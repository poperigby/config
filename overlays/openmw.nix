final: prev: {
    openmw = prev.openmw.overrideAttrs (old: {
        src = prev.fetchFromGitLab {
            owner = "OpenMW";
            repo = "openmw";
            rev = "master";
            hash = "sha256-QpHWGmBC4lpZY0QcNGUpSPDBkMKfOSFdHrSsH4ZtRwk=";
        };
    });
}
