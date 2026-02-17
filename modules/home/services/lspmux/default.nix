{
    config,
    lib,
    pkgs,
    ...
}:
let
    inherit (lib) getExe mkEnableOption mkIf;

    cfg = config.custom.services.lspmux;
in
{
    options.custom.services.lspmux.enable = mkEnableOption "lspmux";
    config = mkIf cfg.enable {
        home.packages = [ pkgs.lspmux ];

        systemd.user.services.lspmux = {
            Unit = {
                Description = "Language server multiplexer";
                After = [ "network.target" ];
            };
            Service = {
                Type = "simple";
                ExecStart = "${getExe pkgs.lspmux} server";
                Restart = "on-failure";
                RestartSec = 3;
            };
            Install.WantedBy = [ "default.target" ];
        };
    };
}
