# Screenshot tool

{ ... }:

{
    services.flameshot = {
        enable = true;
        settings = {
            General = {
                disabledTrayIcon = true;
            };
        };
    };
}
