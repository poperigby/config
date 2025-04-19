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
  options.custom.programs.thunderbird.enable = mkEnableOption "thunderbird";

  config = mkIf cfg.enable {
    programs.thunderbird = {
      enable = true;
      package = pkgs.thunderbird-latest;
      profiles.cassidy = {
        isDefault = true;
        settings =
          let
            contactsAccount = config.accounts.contact.accounts.${user};
            contactsAccountSafeName = builtins.replaceStrings [ "." ] [ "-" ] contactsAccount.name;
          in
          {
            # Use system emoji font
            "font.name-list.emoji" = "emoji";
            # Automatically enable extensions
            "extensions.autoDisableScopes" = 0;
            # Contacts
            "ldap_2.servers.${contactsAccountSafeName}.carddav.url" = contactsAccount.remote.url;
            "ldap_2.servers.${contactsAccountSafeName}.carddav.username" = contactsAccount.remote.userName;
            "ldap_2.servers.${contactsAccountSafeName}.description" = contactsAccount.name;
            "ldap_2.servers.${contactsAccountSafeName}.dirType" = 102;
            "ldap_2.servers.${contactsAccountSafeName}.filename" = "abook-${contactsAccountSafeName}.sqlite";
          };
      };
    };

    accounts.email.accounts.${user}.thunderbird.enable = true;
  };
}
