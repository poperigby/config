{ config, ... }:

{
    services.miniflux = {
        enable = true;
        adminCredentialsFile = config.sops.templates.miniflux-secrets.path;
        config = {};
    };


    sops.templates.miniflux-secrets = {
        owner = "miniflux";
        content = ''
            ADMIN_USERNAME="${config.sops.placeholder."haddock/miniflux/admin_username"}"
            ADMIN_PASSWORD="${config.sops.placeholder."haddock/miniflux/admin_password"}"
        '';
    };
}
