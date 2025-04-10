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
in
{
  options.custom.programs.thunderbird.enable = mkEnableOption "Enable thunderbird";

  config = mkIf cfg.enable {
    programs.thunderbird = {
      enable = true;
      package = pkgs.thunderbird-latest;
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
