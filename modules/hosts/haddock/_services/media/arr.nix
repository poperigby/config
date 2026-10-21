{ config, lib, ... }:

let
    inherit (lib.local.caddy) authReverseProxy authReverseProxy';

    netns = "proton";
in
{
    # Groups are set to "media" to give *arr access to /mnt/media/data, and make hardlinks work
    services = {
        # Automatically grab subtitles
        bazarr = {
            enable = true;
            group = "media";
        };

        # Automatically grab music
        lidarr = {
            enable = true;
            group = "media";
        };

        # Manage indexers and sync them with *arr apps
        prowlarr.enable = true;

        # Automatically grab movies
        radarr = {
            enable = true;
            group = "media";
        };

        # Automatically grab books
        readarr = {
            enable = true;
            group = "media";
        };

        # Automatically grab TV shows
        sonarr = {
            enable = true;
            group = "media";
        };

        caddy.virtualHosts =
            let
                namespaceAddress = config.vpnNamespaces.${netns}.namespaceAddress;
            in
            {
                "subtitles.haddock.cc".extraConfig = authReverseProxy config.services.bazarr.settings.general.port;
                "music.haddock.cc".extraConfig = authReverseProxy' namespaceAddress 8686;
                "indexers.haddock.cc".extraConfig = authReverseProxy' namespaceAddress 9696;
                "movies.haddock.cc".extraConfig = authReverseProxy' namespaceAddress 7878;
                "books.haddock.cc".extraConfig = authReverseProxy' namespaceAddress 8787;
                "tv.haddock.cc".extraConfig = authReverseProxy' namespaceAddress 8989;
            };
    };

    vpnNamespaces.proton = {
        portMappings = [
            # Make web UIs accessible on the bridge interface
            {
                # Lidarr
                from = 8686;
                to = 8686;
            }
            {
                # Prowlarr
                from = 9696;
                to = 9696;
            }
            {
                # Radarr
                from = 7878;
                to = 7878;
            }
            {
                # Readarr
                from = 8787;
                to = 8787;
            }
            {
                # Sonarr
                from = 8989;
                to = 8989;
            }
        ];
    };

    systemd.services = {
        lidarr = {
            environment = {
                LIDARR__AUTH__REQUIRED = "True";
                LIDARR__AUTH__METHOD = "External";
            };
            vpnConfinement = {
                enable = true;
                vpnNamespace = netns;
            };
        };
        prowlarr = {
            environment = {
                PROWLARR__AUTH__REQUIRED = "True";
                PROWLARR__AUTH__METHOD = "External";
            };
            # Make Prowlarr run in the VPN namespace so it has the same IP as qBittorrent
            vpnConfinement = {
                enable = true;
                vpnNamespace = netns;
            };
        };
        radarr = {
            environment = {
                RADARR__AUTH__REQUIRED = "True";
                RADARR__AUTH__METHOD = "External";
            };
            vpnConfinement = {
                enable = true;
                vpnNamespace = netns;
            };
        };
        readarr = {
            environment = {
                READARR__AUTH__REQUIRED = "True";
                READARR__AUTH__METHOD = "External";
            };
            vpnConfinement = {
                enable = true;
                vpnNamespace = netns;
            };
        };
        sonarr = {
            environment = {
                SONARR__AUTH__REQUIRED = "True";
                SONARR__AUTH__METHOD = "External";
            };
            vpnConfinement = {
                enable = true;
                vpnNamespace = netns;
            };
        };
    };
}
