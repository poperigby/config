# TODO: *arr apps need access to everything under data/

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
            "tv.haddock.cc".extraConfig = ''
                import auth
                reverse_proxy :8989
            '';
            "movies.haddock.cc".extraConfig = ''
                import auth
                reverse_proxy :7878
            '';
            "indexers.haddock.cc".extraConfig = ''
                import auth
                reverse_proxy :9696
            '';
        };
    };
}
