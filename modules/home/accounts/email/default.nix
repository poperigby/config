{ config, lib, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.accounts.email;
  user = config.home.username;
in
{
  options.custom.accounts.email.enable = mkEnableOption "email account";

  config = mkIf cfg.enable {
    accounts.email.accounts.${user} = rec {
      primary = true;

      realName = "Cassidy";
      address = "poperigby@mailbox.org";
      aliases = [ "cassidyw@mailbox.org" ];
      passwordCommand = "cat ${config.sops.secrets."common/users/${user}/email/password".path}";

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

    sops.secrets."common/users/${user}/email/password" = { };
  };
}
