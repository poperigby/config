{ config, lib, pkgs, ... }:

let
  cfg = config.poperigby.services.ld;
in
{
    options.poperigby.services.ld.enable = lib.mkEnableOption "Enable nix-ld";

    config = lib.mkIf cfg.enable {
        # Allows running random dynamically linked binaries seamlessly
        programs.nix-ld = {
            enable = true;
            # Sets up common libraries to load
            libraries = with pkgs; [
                stdenv.cc.cc
                zlib
                fuse3
                icu
                zlib
                nss
                openssl
                curl
                expat
            ];
        };
    };
}
