{
    fetchFromGitea,
    lib,
    openssl,
    pkg-config,
    rustPlatform,
    ...
}:

rustPlatform.buildRustPackage rec {
    pname = "grabweather";
    version = "0.1.0";

    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ openssl ];

    src = fetchFromGitea {
        domain = "codeberg.org";
        owner = "PopeRigby";
        repo = pname;
        rev = "58ef82bbaf290f8fe3b08f7b5b6050351caa0484";
        hash = "sha256-q1iik6VnHwWw+jo/04t6HPN2xy5+oIMk4aJY4+35nQA=";
    };

    cargoHash = "sha256-f5xz6S6PdlTO8rEhst4AIpf+M2/9AyBzuzPJlCY21eM=";

    meta = with lib; {
        description = "A simple tool that returns the current weather.";
        homepage = "https://codeberg.org/PopeRigby/grabweather";
        license = licenses.gpl3;
        mainProgram = pname;
    };
}
