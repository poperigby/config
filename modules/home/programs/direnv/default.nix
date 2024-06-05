{ config, lib, ... }:

let
    cfg = config.poperigby.programs.direnv;
in
{
    options.poperigby.programs.direnv.enable = lib.mkEnableOption "Enable direnv";

    config = lib.mkIf cfg.enable {
        programs.direnv = {
            enable = true;
            nix-direnv.enable = true;
        };
    };
}
