{ config, pkgs, ... }:

let
    cfg = config.services.nextcloud;
    caddy = config.services.caddy;
    fpm = config.services.phpfpm.pools.nextcloud;
in
{
    services = {
        nextcloud = {
            enable = true;
            # See https://wiki.nixos.org/wiki/Nextcloud#Upgrade for how to upgrade
            package = pkgs.nextcloud29;
            hostName = "cloud.haddock.cc";
            # This attribute set is written to `config.php`
            settings = {
                default_phone_region = "US";
                trusted_proxies = [ "127.0.0.1" ];
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
                inherit (cfg.package.packages.apps)
                contacts
                calendar
                ;
                tasks = pkgs.fetchNextcloudApp {
                    appName = "Tasks";
                    url = "https://github.com/nextcloud/tasks/releases/download/v0.16.0/tasks.tar.gz";
                    sha256 = "";
                    license = "afl3";
                    appVersion = "0.16.0";
                };
                oidc_login = pkgs.fetchNextcloudApp {
                    appName = "OpenID Connect Login";
                    url = "https://github.com/pulsejet/nextcloud-oidc-login/releases/download/v3.1.1/oidc_login.tar.gz";
                    sha256 = "sha256-EVHDDFtz92lZviuTqr+St7agfBWok83HpfuL6DFCoTE=";
                    license = "afl3";
                    appVersion = "3.1.1";
                };
            };
            maxUploadSize = "10G";
        };
        # Caddy setup
        caddy.virtualHosts.${cfg.hostName}.extraConfig = ''
            import auth

            encode zstd gzip

            root * ${config.services.nginx.virtualHosts.${cfg.hostName}.root}

            redir /.well-known/carddav /remote.php/dav 301
            redir /.well-known/caldav /remote.php/dav 301
            redir /.well-known/* /index.php{uri} 301
            redir /remote/* /remote.php{uri} 301

            header {
                Strict-Transport-Security max-age=31536000
                Permissions-Policy interest-cohort=()
                X-Content-Type-Options nosniff
                X-Frame-Options SAMEORIGIN
                Referrer-Policy no-referrer
                X-XSS-Protection "1; mode=block"
                X-Permitted-Cross-Domain-Policies none
                X-Robots-Tag "noindex, nofollow"
                -X-Powered-By
            }

            request_body {
                max_size ${cfg.maxUploadSize}
            }

            php_fastcgi unix/${fpm.socket} {
                root ${config.services.nginx.virtualHosts.${cfg.hostName}.root}
                env front_controller_active true
                env modHeadersAvailable true
            }

            @forbidden {
                path /build/* /tests/* /config/* /lib/* /3rdparty/* /templates/* /data/*
                path /.* /autotest* /occ* /issue* /indie* /db_* /console*
                not path /.well-known/*
            }
            error @forbidden 404

            @immutable {
                path *.css *.js *.mjs *.svg *.gif *.png *.jpg *.ico *.wasm *.tflite
                query v=*
            }
            header @immutable Cache-Control "max-age=15778463, immutable"

            @static {
                path *.css *.js *.mjs *.svg *.gif *.png *.jpg *.ico *.wasm *.tflite
                not query v=*
            }
            header @static Cache-Control "max-age=15778463"

            @woff2 path *.woff2
            header @woff2 Cache-Control "max-age=604800"

            file_server
        '';
        nginx.enable = false;
        phpfpm.pools.nextcloud.settings = {
            "listen.owner" = caddy.user;
            "listen.group" = caddy.group;
        };
    };

    sops.secrets."haddock/nextcloud/admin_password".owner = "nextcloud";
}
