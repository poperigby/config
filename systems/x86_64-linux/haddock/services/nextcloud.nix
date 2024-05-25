{ config, pkgs, ... }:

{
    services.nextcloud = {
        enable = true;
        # See https://wiki.nixos.org/wiki/Nextcloud#Upgrade for how to upgrade
        package = pkgs.nextcloud29;
        hostName = "cloud.haddock.cc";
        # This attribute set is written to `config.php`
        settings = {
            default_phone_region = "US";
            # TODO: Add Caddy
            trusted_proxies = [];
            log_type = "systemd";
        };
        # This attribute set is used by the imperative installer
        config = {
            # Admin
            adminuser = "admin";
            adminpassFile = config.sops.secrets."haddock/nextcloud/admin_password".path;
            # Database
            dbtype = "pgsql";
            dbuser = "nextcloud";
            dbname = "nextcloud";
            dbhost = "/run/postgresql";
        };
        extraApps = {
            inherit (config.services.nextcloud.package.packages.apps) contacts calendar tasks;
        };
        phpExtraExtensions = all: [
            # Required for systemd logging
            all.systemd
        ];
        maxUploadSize = "10G";
    };

    # We want to use Caddy
    services.nginx.enable = false;

    sops.secrets."haddock/nextcloud/admin_password" = {
        owner = "nextcloud";
    };
}
