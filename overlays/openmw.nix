final: prev: {
    openmw = prev.openmw.overrideAttrs (old: {
        src = prev.fetchFromGitLab {
            owner = "OpenMW";
            repo = "openmw";
            rev = "master";
            hash = "sha256-jkidf6U6TbpQMkiJaxNE/ii8hgGnI5Cu7K2++/yXPg8=";
        };
    });
}
