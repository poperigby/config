{ config, lib, ... }:

let
    cfg = config.services.lldap;
in
{
    # TODO: Have a special user for Authelia access
    services = {
        lldap = {
            enable = true;
            settings = {
                ldap_base_dn = "dc=haddock,dc=cc";
                database_url = "postgresql://lldap@localhost/lldap?host=/run/postgresql";
            };
            environment = {
                LLDAP_JWT_SECRET_FILE = config.sops.secrets."haddock/lldap/jwt_secret".path;
                LLDAP_KEY_SEED_FILE = config.sops.secrets."haddock/lldap/key_seed".path;
                LLDAP_LDAP_USER_PASS_FILE = config.sops.secrets.lldap-admin-password-lldap.path;
            };
        };
        caddy.virtualHosts."users.haddock.cc".extraConfig = ''
            import auth
            reverse_proxy localhost:${builtins.toString cfg.settings.http_port}
        '';
    };

    systemd.services.lldap = {
        # LLDAP requires PostgreSQL to be running
        unitConfig.BindsTo = "postgresql.service";
        # DynamicUser screws up sops-nix ownership because
        # the user doesn't exist outside of runtime.
        serviceConfig.DynamicUser = lib.mkForce false;
    };

    # Setup a user and group for LLDAP
    users = {
        users.lldap = {
            group = "lldap";
            isSystemUser = true;
        };
        groups.lldap = {};
    };

    sops.secrets = {
        "haddock/lldap/jwt_secret".owner = "lldap";
        "haddock/lldap/key_seed".owner = "lldap";
        lldap-admin-password-lldap = {
            owner = "lldap";
            key = "haddock/lldap/admin_password";
        };
    };
}
