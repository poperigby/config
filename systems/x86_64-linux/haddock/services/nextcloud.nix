{ config, pkgs, ... }:

{
    services.nextcloud = {
        enable = true;
        # See https://wiki.nixos.org/wiki/Nextcloud#Upgrade for how to upgrading
        package = pkgs.nextcloud29;
        hostName = "cloud.haddock.cc";
        settings = {
            default_phone_region = "US";
            # TODO: Add Caddy
            trusted_proxies = [];
            log_type = "systemd";
        };
        config = {
            # Database
            dbtype = "pgsql";
            dbuser = "nextcloud";
            dbname = "nextcloud";
            dbhost = "/run/postgresql";
            # Admin
            adminuser = "admin";
            # adminpassFile = ;
        };
        extraApps = {
            inherit (config.services.nextcloud.package.packages.apps) news contacts calendar tasks;
        };
        phpExtraExtensions = all: [
            # Required for systemd logging
            all.systemd
        ];
        maxUploadSize = "10G";
    };
}
