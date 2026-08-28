final: prev:
let
    revision = "0d6263ac5f6ad191509c7109d53ef55767446ba4";
in
{
    uzdoom = prev.uzdoom.overrideAttrs (old: {
        src = prev.fetchFromGitHub {
            owner = "UZDoom";
            repo = "UZDoom";
            rev = revision;
            hash = "sha256-iFfLuc4HBoEJNcmQCfvSDVvtKdWIXDZsSmLF0b+oJqE=";
        };

        nativeBuildInputs = old.nativeBuildInputs ++ [
            prev.python3
        ];

        postPatch = ''
            substituteInPlace cmake/UpdateRevision.cmake \
              --replace-fail "unknown" "${revision}"
        '';
    });
}
