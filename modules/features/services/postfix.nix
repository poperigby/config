{ ... }:
{
    den.aspects.services.provides.postfix.nixos =
        { config, privateInfo, ... }:
        let
            email = privateInfo.poperigby.email;
            postfix = config.services.postfix;
        in
        {
            services.postfix = {
                enable = true;
                settings.main = {
                    myhostname = "haddock.cc";
                    relayhost = [ "[smtp.mailbox.org]:587" ];
                    smtpd_banner = "$myhostname ESMTP";
                    disable_vrfy_command = true;
                    header_size_limit = "4096000";
                    smtp_tls_security_level = "encrypt";
                    smtp_address_preference = "ipv4";
                    smtp_sasl_auth_enable = "yes";
                    smtp_sasl_password_maps = "texthash:${config.sops.templates.postfix-sasl-credentials.path}";
                    smtp_sasl_security_options = "noanonymous";
                    smtp_sasl_tls_security_options = "noanonymous";
                    sender_canonical_maps = "static:haddock@mailbox.org";
                };
                rootAlias = email;
            };

            sops = {
                templates.postfix-sasl-credentials = {
                    owner = postfix.user;
                    content =
                        let
                            smtpPassword = config.sops.placeholder.smtp-password_postfix;
                        in
                        ''
                            ${toString postfix.settings.main.relayhost} ${email}:${smtpPassword}
                        '';
                };
                secrets.smtp-password_postfix = {
                    owner = postfix.user;
                    key = "common/users/cassidy/email/password";
                };
            };
        };
}
