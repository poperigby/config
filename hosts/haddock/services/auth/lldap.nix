{ config, lib, ... }:

{
    services.lldap = {
        enable = true;
        settings = {
            ldap_base_dn = "dc=haddock,dc=cc";
            database_url = "postgresql://localhost/lldap";
        };
        environment = {
            LLDAP_JWT_SECRET_FILE = config.sops.secrets."haddock/lldap/jwt_secret".path;
            LLDAP_LDAP_USER_PASS_FILE = config.sops.secrets."haddock/lldap/admin_password".path;
            LLDAP_KEY_SEED_FILE = config.sops.secrets."haddock/lldap/key_seed".path;
        };
    };

    systemd.services.lldap = {
        unitConfig = {
            # LLDAP requires PostgreSQL to be running
            BindsTo = "postgresql.service";
        };
        serviceConfig = {
            # DynamicUser screws up sops-nix ownership because
            # the user doesn't exist outside of runtime.
            DynamicUser = lib.mkForce false;
        };
    };

    # Setup a user and group for LLDAP
    users = {
        users.lldap = {
            group = "lldap";
            extraGroups = [ "lldap_admin_password" ];
            isSystemUser = true;
        };
        groups = {
            lldap = {};
            # Group to allow other services to view the admin password
            lldap_admin_password = {};
        };
    };

    sops.secrets = {
        "haddock/lldap/jwt_secret" = {
            owner = "lldap";
        };
        "haddock/lldap/admin_password" = {
            owner = "lldap";
            # We also want Authelia to be able to read this
            group = "lldap_admin_password";
        };
        "haddock/lldap/key_seed" = {
            owner = "lldap";
        };
    };
}
