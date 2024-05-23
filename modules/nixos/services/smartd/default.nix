{ config, lib, ... }:

let
  cfg = config.poperigby.services.smartd;
in
{
    options.poperigby.services.smartd = {
        enable = lib.mkEnableOption "Enable smartd to monitor drives";
        mail = {
            enable = lib.mkEnableOption "Enable email notifications";
            senderDomain = lib.mkOption {
                type = lib.types.str;
                default = config.networking.hostName;
                example = "example.com";
                description = "What hostname to use for email notifications";
            };
        };
    };

    config = lib.mkIf cfg.enable {
        services.smartd = {
            enable = true;
            notifications.mail = lib.mkIf cfg.mail.enable {
                enable = true;
                sender = "smartd@${cfg.mail.senderDomain}";
            };
        };

        poperigby.services.postfix.enable = cfg.mail.enable;
    };
}
