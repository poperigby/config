{ ... }:

{
    # Automatically grab TV shows
    services.sonarr.enable = true;

    # Automatically grab movies
    services.radarr.enable = true;

    # Index manager
    services.prowlarr.enable = true;
}
