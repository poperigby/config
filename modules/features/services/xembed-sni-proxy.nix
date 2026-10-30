{ ... }:

{
    den.aspects.services.provides.xembed-sni-proxy.homeManager =
        {
            lib,
            pkgs,
            ...
        }:
        let
            # niri exports DISPLAY to the user manager slightly after
            # graphical-session.target starts, and Qt aborts without it.
            waitForDisplay = pkgs.writeShellApplication {
                name = "xembed-sni-proxy-wait-for-display";
                runtimeInputs = with pkgs; [
                    gnugrep
                    systemd
                ];
                text = ''
                    until systemctl --user show-environment | grep -q '^DISPLAY='; do
                        sleep 0.1
                    done
                '';
            };
        in
        {
            home.packages = [ pkgs.local.xembed-sni-proxy ];

            systemd.user.services.xembed-sni-proxy = {
                Unit = {
                    Description = "Standalone xembed system tray to StatusNotifierItem proxy";
                    PartOf = [ "graphical-session.target" ];
                };
                Service = {
                    Type = "simple";
                    ExecStartPre = lib.getExe waitForDisplay;
                    TimeoutStartSec = 30;
                    ExecStart = lib.getExe pkgs.local.xembed-sni-proxy;
                    Restart = "on-failure";
                };
                Install.WantedBy = [ "graphical-session.target" ];
            };
        };
}
