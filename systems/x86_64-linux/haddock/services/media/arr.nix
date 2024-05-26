{ ... }:

{
    services = {
        # Automatically grab TV shows
        sonarr.enable = true;

        # Automatically grab movies
        radarr.enable = true;

        # Index manager
        prowlarr.enable = true;

        caddy.virtualHosts = {
            "tv.haddock.cc".extraConfig = "reverse_proxy localhost:8989";
            "movies.haddock.cc".extraConfig = "reverse_proxy localhost:7878";
            "indexers.haddock.cc".extraConfig = "reverse_proxy localhost:9696";
        };
    };
}
