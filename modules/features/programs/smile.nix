{ ... }:

{
    den.aspects.programs.provides.smile.homeManager =
        { lib, pkgs, ... }:
        {
            home.packages = [ pkgs.smile ];

            systemd.user.services.smile-autopaste = {
                Unit = {
                    Description = "Automatically paste emoji selected in Smile";
                    After = "graphical-session.target";
                };
                Service = {
                    Type = "simple";
                    ExecStart = lib.getExe (
                        pkgs.writeShellApplication {
                            name = "smile-autopaste";
                            runtimeInputs = [ pkgs.dotool ];
                            text = # bash
                                ''
                                    dbus-monitor --session "type='signal',interface='it.mijorus.smile',member='CopiedEmojiBroadcast',path='/it/mijorus/smile/actions'" | \
                                    while read -r line; do
                                        if echo "$line" | grep -q "member=CopiedEmojiBroadcast"; then
                                            echo 'key ctrl+v' | dotool
                                        fi
                                    done
                                '';
                        }
                    );
                    Restart = "on-failure";
                    RestartSec = 5;
                };
                Install.WantedBy = [ "default.target" ];

            };
        };
}
