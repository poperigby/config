{ pkgs, ... }:

{
    services.resolved.enable = false;

    services.unbound = {
        enable = true;
        package = pkgs.unbound.override {
            withSystemd = true;
            withRedis = true;
        };
        settings = {
            server = {
                interface = [
                    "127.0.0.1"
                    "::1"
                    "172.17.0.1"
                ];
                access-control = [
                    "127.0.0.0/8 allow"
                    "::1/128 allow"
                    "172.17.0.0/16 allow"
                ];

                # https://continuwuity.org/guides/dns.html#unbound
                rrset-cache-size = "512M";
                msg-cache-size = "256M";
                key-cache-size = "64M";
                neg-cache-size = "16M";
                rrset-cache-slabs = 8;
                msg-cache-slabs = 8;
                key-cache-slabs = 8;
                infra-cache-slabs = 8;
                infra-cache-numhosts = 100000;

                prefetch = true;
                serve-expired = true;
                serve-expired-client-timeout = 0;
                serve-expired-reply-ttl = 30;
                discard-timeout = "4800";

                module-config = ''"validator cachedb iterator"'';

                num-threads = 8;
                so-reuseport = true;
                outgoing-range = 8192;
                num-queries-per-thread = 4096;

                # Avoid using up application ports
                outgoing-port-avoid = "32768-60999";

                do-ip6 = false;
            };
            cachedb = {
                backend = "redis";
                redis-server-path = "/run/redis-haddock/redis.sock";
                redis-logical-db = 15;
                redis-expire-records = true;
            };
            remote-control.control-enable = true;
        };
    };

    users.users.unbound.extraGroups = [ "redis-haddock" ];

    systemd.services.unbound = {
        after = [ "redis-haddock.service" ];
        wants = [ "redis-haddock.service" ];
        serviceConfig.LimitNOFILE = 131072;
    };

    networking.firewall.interfaces.docker0 = {
        allowedTCPPorts = [ 53 ];
        allowedUDPPorts = [ 53 ];
    };

    virtualisation.docker.daemon.settings = {
        bip = "172.17.0.1/16";
        dns = [ "172.17.0.1" ];
    };
}
