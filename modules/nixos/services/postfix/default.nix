{ config, lib, ... }:

let
  cfg = config.poperigby.services.postfix;
  postfix = config.services.postfix;
  credentialsFile = config.sops.templates.postfix-sasl-credentials.path;
  apiKeyPlaceholder = config.sops.placeholder.sendgrid-api-key-postfix;
in
{
    options.poperigby.services.postfix.enable = lib.mkEnableOption "Enable postfix for sending email";

    config = lib.mkIf cfg.enable {
        services.postfix = {
            enable = true;
            relayHost = "smtp.sendgrid.net";
            relayPort = 587;
            config = {
                header_size_limit = "4096000";
                smtp_tls_security_level = "encrypt";

                # SASL
                smtp_sasl_auth_enable = "yes";
                smtp_sasl_password_maps = "texthash:${credentialsFile}";
                smtp_sasl_security_options = "noanonymous";
                smtp_sasl_tls_security_options = "noanonymous";
            };
        };

        sops.templates.postfix-sasl-credentials = {
            owner = postfix.user;
            content = ''
                [${postfix.relayHost}]:${builtins.toString postfix.relayPort} apikey:${apiKeyPlaceholder}
            '';
        };

        sops.secrets.sendgrid-api-key-postfix = {
            owner = postfix.user;
            key = "common/sendgrid/api_key";
        };
    };
}
