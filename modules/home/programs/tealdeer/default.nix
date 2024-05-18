{ config, lib, ... }:

let
    cfg = config.poperigby.programs.tealdeer;
in
{
    options.poperigby.programs.tealdeer.enable = lib.mkEnableOption "Enable tealdeer";

    config = lib.mkIf cfg.enable {
        programs.tealdeer = {
            enable = true;
            settings.updates.auto_update = true;
        };
    };
}
