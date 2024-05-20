{ ... }:

{
    services = {
        # Automatically grab TV shows
        sonarr.enable = true;

        # Automatically grab movies
        radarr.enable = true;

        # Index manager
        prowlarr.enable = true;
    };
}
