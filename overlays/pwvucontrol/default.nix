{ ... }:

final: prev: {
    pwvucontrol = prev.pwvucontrol.overrideAttrs (old: rec {
        version = "0.4.1";

        src = prev.fetchFromGitHub {
            owner = "saivert";
            repo = "pwvucontrol";
            rev = "016a6e737c126971e95843441f21a79b881ba32d";
            sha256 = "sha256-cWNWdCMk9hF8Nzq2UFBEKSx1zS8JlplMG7B5gv7BaZA=";
        };

        cargoDeps = prev.rustPlatform.importCargoLock {
            lockFile = "${src}/Cargo.lock";
            outputHashes = {
                "wireplumber-0.1.0" = "sha256-r3p4OpmMgiFgjn1Fj4LeMOhx6R2UWollIdJRy/0kiNM=";
            };
        };
    });
}
