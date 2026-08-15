{
    config,
    lib,
    privateInfo,
    ...
}:

let
    inherit (lib) mkForce;
    inherit (lib.local.caddy) authReverseProxy;

    cfg = config.services.scrutiny;
in
{
    services = {
        scrutiny = {
            enable = true;
            settings = {
                web.listen.port = 8082;
            };
            collector = {
                # Why is this disabled by default?
                enable = true;
            };
        };
        caddy.virtualHosts."drives.haddock.cc".extraConfig = authReverseProxy cfg.settings.web.listen.port;
    };

    systemd.services.scrutiny.serviceConfig = {
        DynamicUser = mkForce false;
        EnvironmentFile = config.sops.templates.scrutiny-secrets.path;
    };

    # Setup a user and group for Scrutiny
    users = {
        users.scrutiny = {
            group = "scrutiny";
            isSystemUser = true;
        };
        groups.scrutiny = { };
    };

    sops = {
        templates.scrutiny-secrets = {
            content =
                let
                    email = privateInfo.poperigby.email;
                in
                with config.sops.placeholder;
                ''
                    SCRUTINY_NOTIFY_URLS="smtp://${email}:${smtp-password_scrutiny}@smtp.mailbox.org:587/?from=haddock@mailbox.org&to=${email}"
                '';
            owner = "scrutiny";
        };
        secrets = {
            smtp-password_scrutiny = {
                key = "common/users/cassidy/email/password";
                owner = "scrutiny";
            };
        };
    };
}
