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
      contact.accounts.Default.remote = {
        type = "carddav";
        url = "https://dav.haddock.cc/carddav/principal/cassidy/default/";
        userName = "cassidy";
        passwordCommand = "cat ${config.sops.secrets."common/users/cassidy/contacts/password".path}";
      };
      email.accounts.cassidy = rec {
        primary = true;

        realName = "PopeRigby";
        address = "poperigby@mailbox.org";
        aliases = [
          {
            realName = "Cassidy Wilson";
            address = "cassidyw@mailbox.org";
          }
        ];
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
