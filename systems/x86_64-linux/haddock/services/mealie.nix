{ config, lib, ... }:

{
    services.miniflux = {
        enable = true;
        # credentialsFile = config.sops.templates.mealie-secrets.path;
        settings = {
            ALLOW_SIGNUP = "false";
            MAX_WORKERS = "1";
            WEB_CONCURRENCY = "1";
            BASE_URL = "https://food.haddock.cc";
            # LLDAP settings
            # LDAP_AUTH_ENABLED = "true";
            # LDAP_SERVER_URL = "";
            # LDAP_BASE_DN = "ou=people,dc=haddock,dc=cc";
            # LDAP_QUERY_BIND = "cn=readonly,ou=people,dc=haddock,dc=cc";
            # LDAP_ID_ATTRIBUTE = "uid";
            # LDAP_NAME_ATTRIBUTE = "displayName";
            # LDAP_MAIL_ATTRIBUTE = "mail";
        };
    };

    systemd.services.mealie = {
        # DynamicUser screws up sops-nix ownership because
        # the user doesn't exist outside of runtime.
        # serviceConfig.DynamicUser = lib.mkForce false;
        # LLDAP is required for user management
        unitConfig.BindsTo = [ "lldap.service" ];
    };

    # Setup a user and group for Mealie
    # users = {
    #     users.mealie = {
    #         group = "mealie";
    #         isSystemUser = true;
    #     };
    #     groups.mealie = {};
    # };


    # sops = {
    #     templates.mealie-secrets = {
    #         owner = "mealie";
    #         content = ''
    #             LDAP_QUERY_PASSWORD="${config.sops.placeholder."haddock/mealie/ldap_query_password"}"
    #         '';
    #     };
    #     secrets = {
    #         "haddock/mealie/ldap_query_password" = {};
    #     };
    # };
}
