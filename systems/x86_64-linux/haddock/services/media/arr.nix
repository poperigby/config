{ ... }:

{
  # Groups are set to "media" to give *arr access to /mnt/media/data, and make hardlinks work
  services = {
    # Automatically solve Cloudflare challenges
    flaresolverr.enable = true;

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

    caddy.virtualHosts = {
      "indexers.haddock.cc".extraConfig = ''
        import auth
        reverse_proxy :9696
      '';
      "movies.haddock.cc".extraConfig = ''
        import auth
        reverse_proxy :7878
      '';
      "books.haddock.cc".extraConfig = ''
        import auth
        reverse_proxy :8787
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
    readarr.environment = {
      READARR__AUTH__REQUIRED = "True";
      READARR__AUTH__METHOD = "External";
    };
    sonarr.environment = {
      SONARR__AUTH__REQUIRED = "True";
      SONARR__AUTH__METHOD = "External";
    };
  };
}
