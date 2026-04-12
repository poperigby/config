{ ... }:
{
    den.aspects.services.provides.joystickwake.homeManager =
        { lib, pkgs, ... }:
        {
            systemd.user.services.joystickwake = {
                Unit = {
                    Description = "Wake screensaver/DPMS when using joystick";
                    PartOf = [ "graphical-session.target" ];
                };
                Service = {
                    Type = "simple";
                    ExecStart = lib.getExe pkgs.joystickwake;
                    Restart = "on-failure";
                };
                Install.WantedBy = [ "graphical-session.target" ];
            };
        };
}
