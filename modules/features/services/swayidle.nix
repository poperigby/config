{ den, ... }:
{
    den.aspects.services.provides.swayidle =
        {
            timeouts ? {
                lock = 1800;
                sleep = 3600;
            },
        }:
        {
            homeManager =
                { config, lib, ... }:
                let
                    swaylock = lib.getExe config.programs.swaylock.package;
                in
                {
                    services.swayidle = {
                        enable = true;
                        events = [
                            {
                                event = "before-sleep";
                                command = "${swaylock} -fF";
                            }
                            {
                                event = "lock";
                                command = "lock";
                            }
                        ];
                        timeouts = [
                            {
                                timeout = timeouts.lock;
                                command = "${swaylock} -fF";
                            }
                            {
                                timeout = timeouts.sleep;
                                command = "systemctl suspend";
                            }
                        ];
                    };
                };
        };
}
