{ config, ... }:

{
    services.authelia.instances.haddock = {
        enable = true;
        settings = {
            theme = "auto";
            authentication_backend.ldap = {
                url = "ldap://localhost:3890";
                base_dn = "dc=haddock,dc=cc";
                users_filter = "(&({username_attribute}={input})(objectClass=person))";
                groups_filter = "(member={dn})";
                user = "uid=admin,ou=people,dc=haddock,dc=cc";
            };
            storage.postgres = {
               host = "/run/postgresql";
               port = 5432;
               database = "authelia-haddock";
               username = "authelia-haddock";
               # I'm using peer authentication, so this doesn't actually matter, but Authelia
               # complains if I don't have it.
               password = "authelia-haddock";
            };
            session.domain = "https://haddock.cc";
            notifier.smtp = {
                username = "apikey";
                host = "smtp.sendgrid.net";
                port = 587;
                sender = "admin@haddock.cc";
            };
            access_control = {
                default_policy = "deny";
                rules = [
                    {
                        domain = "*.haddock.cc";
                        policy = "one_factor";
                    }
                ];
            };
        };
        secrets = {
            jwtSecretFile = config.sops.secrets."haddock/authelia/jwt_secret".path;
            storageEncryptionKeyFile = config.sops.secrets."haddock/authelia/storage_encryption_key".path;
            sessionSecretFile = config.sops.secrets."haddock/authelia/session_secret".path;
        };
        environmentVariables = {
            AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE = config.sops.secrets.lldap-admin-password-authelia.path;
            AUTHELIA_NOTIFIER_SMTP_PASSWORD_FILE = config.sops.secrets.smtp-password-authelia.path;
        };
    };

    # Authelia requires LLDAP and PostgreSQL to be running
    systemd.services.authelia-haddock.unitConfig.BindsTo = [
        "lldap.service"
        "postgresql.service"
    ];

    sops.secrets = {
        "haddock/authelia/jwt_secret" = {
            owner = "authelia-haddock";
        };
        "haddock/authelia/storage_encryption_key" = {
            owner = "authelia-haddock";
        };
        "haddock/authelia/session_secret".owner = "authelia-haddock";
        lldap-admin-password-authelia = {
            owner = "authelia-haddock";
            key = "haddock/lldap/admin_password";
        };
        smtp-password-authelia = {
            owner = "authelia-haddock";
            key = "haddock/common/smtp_password";
        };
    };

}
