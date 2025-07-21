{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.programs.thunderbird;
  user = config.home.username;
in
{
  options.custom.programs.thunderbird.enable = mkEnableOption "Thunderbird";

  config = mkIf cfg.enable {
    programs.thunderbird = {
      enable = true;
      package = pkgs.thunderbird-latest;
      profiles.cassidy = {
        isDefault = true;
        settings = {
          # Use system emoji font
          "font.name-list.emoji" = "emoji";
          # Automatically enable extensions
          "extensions.autoDisableScopes" = 0;
        };
      };
    };

    accounts = {
      contact.accounts.${user}.thunderbird.enable = true;
      email.accounts.${user}.thunderbird.enable = true;
    };
  };
}
