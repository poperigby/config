{ ... }:
{
    den.aspects.services.provides.udisks = {
        nixos.services.udisks2.enable = true;
        homeManager = {
            services.udiskie = {
                enable = true;
                tray = "never";
            };
        };
    };
}
