{ config, ... }:

{
    sops.secrets = {
        "haddock/lldap/jwt_secret" = {
            owner = "lldap";
        };
        "haddock/lldap/admin_password" = {
            owner = "lldap";
        };
        "haddock/lldap/key_seed" = {
            owner = "lldap";
        };
    };

    services.lldap = {
        enable = true;
        settings = {
            database_url = "postgres://lldap@localhost/lldap";
            ldap_base_dn = "dc=haddock,dc=cc";
        };
        environment = {
            LLDAP_JWT_SECRET_FILE = config.sops.secrets."haddock/lldap/jwt_secret".path;
            LLDAP_LDAP_USER_PASS_FILE = config.sops.secrets."haddock/lldap/admin_password".path;
            LLDAP_KEY_SEED_FILE = config.sops.secrets."haddock/lldap/key_seed".path;
        };
    };

    systemd.services.lldap.serviceConfig = {
        # DynamicUser screws up sops-nix ownership because
        # the user doesn't exist outside of runtime.
        DynamicUser = false;
    };
}
