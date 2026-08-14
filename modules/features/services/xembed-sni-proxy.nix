{ ... }:

{
    den.aspects.services.provides.xembed-sni-proxy.homeManager =
        {
            lib,
            pkgs,
            ...
        }:
        {
            home.packages = [ pkgs.local.xembed-sni-proxy ];

            systemd.user.services.xembed-sni-proxy = {
                Unit = {
                    Description = "Standalone xembed system tray to StatusNotifierItem proxy";
                    PartOf = [ "graphical-session.target" ];
                };
                Service = {
                    Type = "simple";
                    ExecStart = lib.getExe pkgs.local.xembed-sni-proxy;
                    Restart = "on-failure";
                };
                Install.WantedBy = [ "graphical-session.target" ];
            };
        };
}
