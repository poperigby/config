{ config, lib, ... }:

let
  cfg = config.poperigby.accounts.email;
in
{
    options.poperigby.accounts.email.enable = lib.mkEnableOption "email account";

    config = lib.mkIf cfg.enable {
        accounts.email.accounts.poperigby = rec {
            primary = true;

            realName = "PopeRigby";
            address = "poperigby@mailbox.org";
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

        sops.secrets."common/users/cassidy/email/password" = {};
    };
}
