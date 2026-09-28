{ pkgs, ... }:

{
    services.redis = {
        package = pkgs.valkey;
        servers.haddock = {
            enable = true;
            settings = {
                maxmemory = "64M";
                maxmemory-policy = "allkeys-lru";
            };
        };
    };
}
