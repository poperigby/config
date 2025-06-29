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
      relayHost = "smtp.mailbox.org";
      relayPort = 587;
      hostname = "haddock.cc";
      config = {
        # Don't expose software information in the banner
        smtpd_banner = "$myhostname ESMTP";

        # Disable the VRFY command
        # https://linux-audit.com/postfix-hardening-guide-for-security-and-privacy/#disable-vrfy-verify
        disable_vrfy_command = true;

        header_size_limit = "4096000";
        smtp_tls_security_level = "encrypt";
        smtp_address_preference = "ipv4";

        # SASL
        smtp_sasl_auth_enable = "yes";
        smtp_sasl_password_maps = "texthash:${config.sops.templates.postfix-sasl-credentials.path}";
        smtp_sasl_security_options = "noanonymous";
        smtp_sasl_tls_security_options = "noanonymous";

        # Rewrite outgoing local mail to use a real address
        sender_canonical_maps = "static:haddock@mailbox.org";
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
              smtpPassword = config.sops.placeholder.smtp-password_postfix;
            in
            ''
              [${postfix.relayHost}]:${toString postfix.relayPort} poperigby@mailbox.org:${smtpPassword}
            '';
        };
      };
      secrets = {
        smtp-password_postfix = {
          owner = postfix.user;
          key = "common/users/cassidy/email/password";
        };
      };
    };
  };
}
