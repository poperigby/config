{ den, ... }:
{
    den.aspects.services.provides.gammastep.homeManager.services.gammastep = {
        enable = true;
        temperature = {
            day = 6500;
            night = 4500;
        };
        provider = "geoclue2";
    };
}
