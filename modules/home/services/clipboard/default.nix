{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.custom.services.clipboard;
in
{
  options.custom.services.clipboard.enable = lib.mkEnableOption "Enable clipboard manager";

  config = lib.mkIf cfg.enable {
    # Stores clipboard items in a database and allows recalling them with a picker
    services.cliphist.enable = true;
    # Remembers clipboard contents when source exits
    systemd.user.services.wl-clip-persist = {
      Unit = {
        Description = "Remember clipboard contents after source exists";
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.wl-clip-persist}/bin/wl-clip-persist --clipboard regular";
        Restart = "on-failure";
      };
      Install = {
        WantedBy = [ "graphical.target" ];
      };
    };
  };
}
