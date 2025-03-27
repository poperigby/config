{ config, ... }:

let
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
        "subtitles.haddock.cc".extraConfig = ''
          import auth
          reverse_proxy ${namespaceAddress}:${toString config.services.bazarr.listenPort}
          # reverse_proxy :6767
        '';
        "indexers.haddock.cc".extraConfig = ''
          import auth
          reverse_proxy ${namespaceAddress}:9696
        '';
        "movies.haddock.cc".extraConfig = ''
          import auth
          reverse_proxy ${namespaceAddress}:7878
        '';
        "books.haddock.cc".extraConfig = ''
          import auth
          reverse_proxy ${namespaceAddress}:8787
        '';
        "tv.haddock.cc".extraConfig = ''
          import auth
          reverse_proxy ${namespaceAddress}:8989
        '';
      };
  };

  systemd.services = {
    bazarr = {
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
