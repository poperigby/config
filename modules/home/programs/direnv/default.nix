{ config, lib, ... }:

let
  cfg = config.custom.programs.direnv;
in
{
  options.custom.programs.direnv.enable = lib.mkEnableOption "Enable direnv";

  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
