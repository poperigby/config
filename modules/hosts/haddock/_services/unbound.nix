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
                # https://continuwuity.org/advanced/dns#unbound
                rrset-cache-size = "64M";
                msg-cache-size = "64M";
                discard-timeout = "4800";
                module-config = ''"validator cachedb iterator"'';
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
