{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.custom.services.ld;
in
{
  options.custom.services.ld.enable = lib.mkEnableOption "Enable nix-ld";

  config = lib.mkIf cfg.enable {
    # Allows running random dynamically linked binaries seamlessly
    programs.nix-ld = {
      enable = true;
      # Sets up common libraries to load
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
