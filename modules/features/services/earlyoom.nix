{ ... }:
{
    den.aspects.services.provides.earlyoom.nixos.services.earlyoom = {
        enable = true;
        freeMemThreshold = 5;
        enableNotifications = true;
    };
}
