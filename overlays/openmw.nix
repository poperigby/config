final: prev: {
    openmw = prev.openmw.overrideAttrs (old: {
        src = prev.fetchFromGitLab {
            owner = "OpenMW";
            repo = "openmw";
            rev = "master";
            hash = "sha256-vkOpFEwMpy1kXCHqNmf6jvFZpMu5S4sxeLjagXi9WI8=";
        };
    });
}
