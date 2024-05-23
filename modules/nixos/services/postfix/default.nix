{ config, lib, ... }:

let
  cfg = config.poperigby.services.postfix;
in
{
    options.poperigby.services.postfix.enable = lib.mkEnableOption "Enable postfix to send e-mail through SendGrid";

    config = lib.mkIf cfg.enable {
        services.postfix = {
            enable = true;
            config = {
                smtp_sasl_auth_enable = "yes";
                smtp_sasl_password_maps = "hash:${config.sops.secrets.sengrid-api-key-postfix.path}";
                smtp_sasl_security_options = "noanonymous";
                smtp_sasl_tls_security_options = "noanonymous";
                smtp_tls_security_level = "encrypt";
                header_size_limit = 4096000;
                relayhost = "[smtp.sendgrid.net]:587";
            };
        };

        sops.templates.postfix-sasl-secrets = {
            owner = "postfix";
            content = ''
                [smtp.sendgrid.net]:587 apikey:${config.sops.secrets.sengrid-api-key-postfix}
            '';
        };

        sops.secrets.sengrid-api-key-postfix = {
            owner = "postfix";
            key = "common/sendgrid/api_key";
        };
    };
}
