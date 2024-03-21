{ config, ... }:

{
    services.authelia.instances.haddock = {
        enable = true;
        settings = {
            theme = "auto";
            authentication_backend = {
                ldap = {
                    address = "ldap://localhost:3890";
                    base_dn = "dc=haddock,dc=cc";
                    users_filter = "(&({username_attribute}={input})(objectClass=person))";
                    groups_filter = "(member={dn})";
                    user = "uid=admin,ou=people,dc=haddock,dc=cc";
                };
            };
            storage = {
                local.path = "/var/lib/authelia-haddock/db.sqlite3";
            };
            session = {
                url = "https://haddock.cc";
            };
            # notifier = {};
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
        # environmentVariables = {
        #     AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE = config.sops.secrets."haddock/lldap/admin_password".path;
        # };
    };

    sops.secrets = {
        "haddock/authelia/jwt_secret" = {
            owner = "authelia-haddock";
        };
        "haddock/authelia/storage_encryption_key" = {
            owner = "authelia-haddock";
        };
        "haddock/authelia/session_secret" = {
            owner = "authelia-haddock";
        };
    };

}
