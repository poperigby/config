{
    lib,
    rustPlatform,
    fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
    pname = "reef";
    version = "0.1.3";

    src = fetchFromGitHub {
        owner = "ZStud";
        repo = "reef";
        rev = "v${version}";
        hash = "sha256-mKsTEaPLvJ/DjWrHn1NYcyzsJFMtWg1ga74yJ9QFPRM=";
    };

    cargoHash = "sha256-AxRplHawIYUITjOPTNVn+4roE9Wa1WfwCNwr3yund9I=";

    meta = {
        description = "Paste bash into fish. It just works";
        homepage = "https://github.com/ZStud/reef";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ PopeRigby ];
        mainProgram = "reef";
    };
}
