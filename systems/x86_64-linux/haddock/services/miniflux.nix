{ config, lib, ... }:

{
    services.miniflux = {
        enable = true;
        adminCredentialsFile = config.sops.templates.miniflux-secrets.path;
        config = {
            PORT = "8081";
        };
    };

    systemd.services.miniflux = {
        # DynamicUser screws up sops-nix ownership because
        # the user doesn't exist outside of runtime.
        serviceConfig.DynamicUser = lib.mkForce false;
    };

    # Setup a user and group for Miniflux
    users = {
        users.miniflux = {
            group = "miniflux";
            isSystemUser = true;
        };
        groups.miniflux = {};
    };

    sops.templates.miniflux-secrets = {
        owner = "miniflux";
        content = ''
            ADMIN_USERNAME="admin"
            ADMIN_PASSWORD="${config.sops.placeholder."haddock/miniflux/admin_password"}"
        '';
    };

    sops.secrets = {
        "haddock/miniflux/admin_password" = {};
    };
}
