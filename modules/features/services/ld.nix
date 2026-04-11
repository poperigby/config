{ den, ... }:
{
    den.aspects.services.provides.ld.nixos =
        { pkgs, ... }:
        {
            programs.nix-ld = {
                enable = true;
                libraries = with pkgs; [
                    curl
                    expat
                    fuse3
                    icu
                    libGL
                    nss
                    openssl
                    stdenv.cc.cc
                    zlib
                ];
            };
        };
}
