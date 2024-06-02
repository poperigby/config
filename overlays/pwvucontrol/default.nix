{ ... }:

final: prev: {
    pwvucontrol = prev.pwvucontrol.overrideAttrs (old: rec {
        version = "0.4.1";

        src = prev.fetchFromGitHub {
            owner = "saivert";
            repo = "pwvucontrol";
            rev = "0.4.1";
            sha256 = "sha256-soxB8pbbyYe1EXtopq1OjoklEDJrwK6od4nFLDwb8LY=";
        };

        cargoDeps = prev.rustPlatform.importCargoLock {
            lockFile = "${src}/Cargo.lock";
            outputHashes = {
                "wireplumber-0.1.0" = "sha256-+LZ8xKok2AOegW8WvfrfZGXuQB4xHrLNshcTOHab+xQ=";
            };
        };
    });
}
