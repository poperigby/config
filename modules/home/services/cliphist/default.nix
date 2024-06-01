{ config, lib, pkgs, ... }:

let
    cfg = config.poperigby.services.cliphist;
in
{
    options.poperigby.services.cliphist.enable = lib.mkEnableOption "Enable Cliphist clipboard manager";

    config = lib.mkIf cfg.enable {
        services.cliphist = {
            enable = true;
        };
    };
}
