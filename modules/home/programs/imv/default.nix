{ config, lib, ... }:

let
    cfg = config.poperigby.programs.imv;
in
{
    options.poperigby.programs.imv.enable = lib.mkEnableOption "Enable imv";

    config = lib.mkIf cfg.enable {
        programs.imv = {
            enable = true;
        };
    };
}
