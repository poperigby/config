{ inputs, ... }:

{
    imports = [
        "${inputs.flaresolverr}/nixos/modules/services/misc/flaresolverr.nix"
    ];

    services = {
        # A proxy server to bypass Cloudflare protection
        flaresolverr = {
            enable = true;
            package = inputs.flaresolverr.legacyPackages.x86_64-linux.flaresolverr;
        };

        # Manage indexers and sync them with *arr apps
        prowlarr.enable = true;

        # Automatically grab movies
        radarr.enable = true;

        # Automatically grab TV shows
        sonarr.enable = true;

        caddy.virtualHosts = {
            "indexers.haddock.cc".extraConfig = ''
                import auth
                reverse_proxy :9696
            '';
            "movies.haddock.cc".extraConfig = ''
                import auth
                reverse_proxy :7878
            '';
            "tv.haddock.cc".extraConfig = ''
                import auth
                reverse_proxy :8989
            '';
        };
    };

    systemd.services = {
        radarr.environment = {
             RADARR__AUTH__REQUIRED = "True";
             RADARR__AUTH__METHOD = "External";
        };
        sonarr.environment = {
             SONARR__AUTH__REQUIRED = "True";
             SONARR__AUTH__METHOD = "External";
        };
    };

    # Give the *arr apps access to data/media and data/torrents
    users.users = let
        groups = [ "media" "torrents" ];
    in {
        radarr.extraGroups = groups;
        sonarr.extraGroups = groups;
    };
}
