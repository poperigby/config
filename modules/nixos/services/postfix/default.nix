{ config, lib, pkgs, ... }:

let
  cfg = config.custom.services.postfix;
  postfix = config.services.postfix;
in
{
    options.custom.services.postfix.enable = lib.mkEnableOption "Enable postfix for sending email";

    config = lib.mkIf cfg.enable {
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

        # A systemd template service for notifying via email when a service fails
        systemd.services."notify-failure-email@" = {
            unitConfig.Description = "Send an email to root notifying that %i failed";
            serviceConfig = {
                Type = "oneshot";
                ExecStart = let
                    hostName = config.networking.hostName;
                    mail = "${pkgs.mailutils}/bin/mail";
                    mailScript = pkgs.writeShellScriptBin "notify-failure-email" ''
                        set -euo pipefail

                        SERVICE=$1

                        echo "The service '$SERVICE' has failed on host '${hostName}'" \
                            | ${mail} -s "Service '$SERVICE' failed on '${hostName}'" root
                    '';
                in "${mailScript}/bin/notify-failure-email %i";
            };
        };

        sops = {
            templates = {
                postfix-sasl-credentials = {
                    owner = postfix.user;
                    content = let
                        apiKey = config.sops.placeholder.sendgrid-api-key_postfix;
                    in ''
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
