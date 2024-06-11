# TODO: *arr apps only need access to everything under data/

{ ... }:

{
    services = {
        # Automatically grab TV shows
        sonarr.enable = true;

        # Automatically grab movies
        radarr.enable = true;

        # Manage indexers and sync them with *arr apps
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
    # Give the *arr apps access to data/media and data/torrents
    users.users = let
        groups = [ "media" "torrents" ];
    in {
        sonarr.extraGroups = groups;
        radarr.extraGroups = groups;
    };
}
