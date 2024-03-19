{ config, ... }:

{
    sops.secrets = {
        "haddock/authelia/jwt_secret" = {
            owner = "authelia-haddock";
        };
        "haddock/authelia/storage_encryption_key" = {
            owner = "authelia-haddock";
        };
    };

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
        };
        secrets = {
            jwtSecretFile = config.sops.secrets."haddock/authelia/jwt_secret".path;
            storageEncryptionKeyFile = config.sops.secrets."haddock/authelia/storage_encryption_key".path;
        };
    };
}
