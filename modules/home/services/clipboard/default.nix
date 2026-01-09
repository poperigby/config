{
    config,
    lib,
    pkgs,
    ...
}:

let
    inherit (lib)
        getExe
        mkEnableOption
        mkIf
        ;

    cfg = config.custom.services.clipboard;
in
{
    options.custom.services.clipboard.enable = mkEnableOption "clipboard manager";

    config = mkIf cfg.enable {
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
                ExecStart = "${getExe pkgs.wl-clip-persist} --clipboard regular";
                Restart = "on-failure";
            };
            Install.WantedBy = [ "graphical.target" ];
        };
    };
}
