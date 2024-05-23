{ config, lib, ... }:

let
  cfg = config.poperigby.services.postfix;
  apiKey = config.sops.secrets.sengrid-api-key-postfix;
  apiKeyPlaceholder = config.sops.placeholder.sengrid-api-key-postfix;
  postfix = config.services.postfix;
in
{
    options.poperigby.services.postfix.enable = lib.mkEnableOption "Enable postfix to send email through SendGrid";

    config = lib.mkIf cfg.enable {
        services.postfix = {
            enable = true;
            relayHost = "smtp.sendgrid.net";
            relayPort = 587;
            config = {
                smtp_sasl_auth_enable = "yes";
                smtp_sasl_password_maps = "texthash:${apiKey.path}";
                smtp_sasl_security_options = "noanonymous";
                smtp_sasl_tls_security_options = "noanonymous";
                smtp_tls_security_level = "encrypt";
                header_size_limit = "4096000";
            };
            mapFiles.sendgrid_credentials = apiKey.path;
        };

        sops.templates.postfix-sasl-secrets = {
            owner = postfix.user;
            content = ''
                [${postfix.relayHost}]:${builtins.toString postfix.relayPort} apikey:${apiKeyPlaceholder}
            '';
        };

        sops.secrets.sengrid-api-key-postfix = {
            owner = postfix.user;
            key = "common/sendgrid/api_key";
        };
    };
}
