{ config, lib, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.accounts.contacts;
  user = config.home.username;
in
{
  options.custom.accounts.contacts.enable = mkEnableOption "CardDAV account";

  config = mkIf cfg.enable {
    accounts.contact.accounts.${user}.remote = {
      passwordCommand = "cat ${config.sops.secrets."common/users/${user}/contacts/password".path}";
      type = "carddav";
      url = "https://dav.haddock.cc/radicale/cassidy/63d95a61-80e1-63f6-7316-70de3b3e7904/";
      userName = user;
    };

    sops.secrets."common/users/${user}/contacts/password" = { };
  };
}
