# https://github.com/NixOS/nixpkgs/issues/513245
final: prev: {
    openldap = prev.openldap.overrideAttrs {
        doCheck = !prev.stdenv.hostPlatform.isi686;
    };
}
