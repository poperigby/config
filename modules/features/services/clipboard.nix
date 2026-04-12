{ ... }:
{
    den.aspects.services.provides.clipboard.homeManager =
        { lib, pkgs, ... }:
        {
            services.cliphist.enable = true;
            systemd.user.services.wl-clip-persist = {
                Unit = {
                    Description = "Remember clipboard contents after source exists";
                    PartOf = [ "graphical-session.target" ];
                };
                Service = {
                    Type = "simple";
                    ExecStart = "${lib.getExe pkgs.wl-clip-persist} --clipboard regular";
                    Restart = "on-failure";
                };
                Install.WantedBy = [ "graphical.target" ];
            };
        };
}
