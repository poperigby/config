{ config, lib, ... }:

let
    cfg = config.custom.programs.tealdeer;
in
{
    options.custom.programs.tealdeer.enable = lib.mkEnableOption "Enable tealdeer";

    config = lib.mkIf cfg.enable {
        programs.tealdeer = {
            enable = true;
            settings.updates.auto_update = true;
        };
    };
}
