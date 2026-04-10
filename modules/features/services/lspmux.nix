{ den, ... }:
{
  den.aspects.services.provides.lspmux.homeManager =
    { lib, pkgs, ... }:
    {
      home.packages = [ pkgs.lspmux ];

      systemd.user.services.lspmux = {
        Unit = {
          Description = "Language server multiplexer";
          After = [ "network.target" ];
        };
        Service = {
          Type = "simple";
          ExecStart = "${lib.getExe pkgs.lspmux} server";
          Restart = "on-failure";
          RestartSec = 3;
        };
        Install.WantedBy = [ "default.target" ];
      };
    };
}

