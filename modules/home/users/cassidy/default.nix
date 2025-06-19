{ config, lib, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.users.cassidy;
in
{
  options.custom.users.cassidy.enable = mkEnableOption "Cassidy user";

  config = mkIf cfg.enable {
    accounts = {
      contact.accounts.cassidy.remote = {
        passwordCommand = "cat ${config.sops.secrets."common/users/cassidy/contacts/password".path}";
        type = "carddav";
        url = "https://dav.haddock.cc/cassidy/63d95a61-80e1-63f6-7316-70de3b3e7904/";
        userName = "cassidy";
      };
      email.accounts.cassidy = rec {
        primary = true;

        realName = "Cassidy";
        address = "poperigby@mailbox.org";
        aliases = [ "cassidyw@mailbox.org" ];
        passwordCommand = "cat ${config.sops.secrets."common/users/cassidy/email/password".path}";

        userName = address;
        imap = {
          host = "imap.mailbox.org";
          port = 993;
        };
        smtp = {
          host = "smtp.mailbox.org";
          port = 465;
        };
      };
    };

    sops.secrets = {
      "common/users/cassidy/email/password" = { };
      "common/users/cassidy/contacts/password" = { };
    };
  };
}
