{ config, lib, ... }:

{
    # Synchronizes Haddock's public IP with Porkbun
    services.ddclient = {
        enable = true;
        configFile = config.sops.templates.ddclient-config.path;
    };

    # DynamicUser screws up sops-nix ownership because
    # the user doesn't exist outside of runtime.
    systemd.services.ddclient.serviceConfig.DynamicUser = lib.mkForce false;

    # Setup a user and group for DDClient
    users = {
        users.ddclient = {
            group = "ddclient";
            isSystemUser = true;
        };
        groups.ddclient = {};
    };

    sops = {
        templates.ddclient-config = {
            content = ''
                protocol=porkbun
                apikey=${config.sops.placeholder."haddock/ddclient/porkbun_api_key"}
                secretapikey=${config.sops.placeholder."haddock/ddclient/porkbun_secret_key"}
                haddock.cc
            '';
            owner = "ddclient";
        };
        secrets = {
            "haddock/ddclient/porkbun_api_key".owner = "ddclient";
            "haddock/ddclient/porkbun_secret_key".owner = "ddclient";
        };
    };
}
