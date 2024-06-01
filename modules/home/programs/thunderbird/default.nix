{ config, lib, ... }:

let
    cfg = config.poperigby.programs.thunderbird;
in
{
    options.poperigby.programs.thunderbird.enable = lib.mkEnableOption "Enable thunderbird";

    config = lib.mkIf cfg.enable {
        programs.thunderbird = {
            enable = true;
            profiles.cassidy = {
                isDefault = true;
            };
        };
    };
}
