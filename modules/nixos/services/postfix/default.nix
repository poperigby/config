{
  config,
  lib,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.services.postfix;
  postfix = config.services.postfix;
in
{
  options.custom.services.postfix.enable = mkEnableOption "Postfix for sending email";

  config = mkIf cfg.enable {
    services.postfix = {
      enable = true;
      relayHost = "smtp.sendgrid.net";
      relayPort = 587;
      config = {
        # Don't expose software information in the banner
        # smtpd_banner = "$myhostname ESMTP";

        # Disable the VRFY command
        # https://linux-audit.com/postfix-hardening-guide-for-security-and-privacy/#disable-vrfy-verify
        disable_vrfy_command = true;

        header_size_limit = "4096000";
        smtp_tls_security_level = "encrypt";

        # SASL
        smtp_sasl_auth_enable = "yes";
        smtp_sasl_password_maps = "texthash:${config.sops.templates.postfix-sasl-credentials.path}";
        smtp_sasl_security_options = "noanonymous";
        smtp_sasl_tls_security_options = "noanonymous";
      };
      # Forward root email to my personal email address
      rootAlias = "poperigby@mailbox.org";
    };

    sops = {
      templates = {
        postfix-sasl-credentials = {
          owner = postfix.user;
          content =
            let
              apiKey = config.sops.placeholder.sendgrid-api-key_postfix;
            in
            ''
              [${postfix.relayHost}]:${toString postfix.relayPort} apikey:${apiKey}
            '';
        };
      };
      secrets = {
        sendgrid-api-key_postfix = {
          owner = postfix.user;
          key = "common/sendgrid/api_key";
        };
      };
    };
  };
}
