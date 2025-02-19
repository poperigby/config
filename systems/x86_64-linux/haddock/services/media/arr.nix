{ ... }:

{
  # Groups are set to "media" to give *arr access to /mnt/media/data, and make hardlinks work
  services = {
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
        netns = "192.168.15.1";
      in
      {
        "indexers.haddock.cc".extraConfig = ''
          import auth
          reverse_proxy ${netns}:9696
        '';
        "movies.haddock.cc".extraConfig = ''
          import auth
          reverse_proxy ${netns}:7878
        '';
        "books.haddock.cc".extraConfig = ''
          import auth
          reverse_proxy ${netns}:8787
        '';
        "tv.haddock.cc".extraConfig = ''
          import auth
          reverse_proxy ${netns}:8989
        '';
      };
  };

  systemd.services = {
    prowlarr = {
      environment = {
        PROWLARR__AUTH__REQUIRED = "True";
        PROWLARR__AUTH__METHOD = "External";
      };
      # Make Prowlarr run in the VPN namespace so it has the same IP as qBittorrent
      vpnConfinement = {
        enable = true;
        vpnNamespace = "proton";
      };
    };
    radarr = {
      environment = {
        RADARR__AUTH__REQUIRED = "True";
        RADARR__AUTH__METHOD = "External";
      };
      vpnConfinement = {
        enable = true;
        vpnNamespace = "proton";
      };
    };
    readarr = {
      environment = {
        READARR__AUTH__REQUIRED = "True";
        READARR__AUTH__METHOD = "External";
      };
      vpnConfinement = {
        enable = true;
        vpnNamespace = "proton";
      };
    };
    sonarr = {
      environment = {
        SONARR__AUTH__REQUIRED = "True";
        SONARR__AUTH__METHOD = "External";
      };
      vpnConfinement = {
        enable = true;
        vpnNamespace = "proton";
      };
    };
  };
}
