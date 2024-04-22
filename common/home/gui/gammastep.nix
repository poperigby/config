# Adjusts screen gamma based on time of day
{ ... }:

{
    services.gammastep = {
        enable = true;
        # Set location provider to geoclue2
        provider = "geoclue2";
    };
}
