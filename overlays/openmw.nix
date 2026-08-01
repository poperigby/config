final: prev: {
    openmw = prev.openmw.overrideAttrs (old: {
        src = prev.fetchFromGitLab {
            owner = "OpenMW";
            repo = "openmw";
            rev = "master";
            hash = "sha256-/0JO/9ocl2hxOrFMSNEi2hMFYlqZoeUZMBzYnYYaeT0=";
        };
    });
}
