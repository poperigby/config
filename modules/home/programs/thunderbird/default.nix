{ config, lib, ... }:

let
    cfg = config.custom.programs.thunderbird;
in
{
    options.custom.programs.thunderbird.enable = lib.mkEnableOption "Enable thunderbird";

    config = lib.mkIf cfg.enable {
        programs.thunderbird = {
            enable = true;
            profiles.cassidy = {
                isDefault = true;
                settings = {
                    # Use system emoji font
                    "font.name-list.emoji" = "emoji";
                };
            };
        };

        accounts.email.accounts.poperigby.thunderbird.enable = true;
    };
}
