{
    config,
    inputs,
    lib,
    system,
    ...
}:

let
    inherit (lib)
        getExe
        mkEnableOption
        mkIf
        mkOption
        ;

    inherit (lib.types)
        nullOr
        path
        str
        ;

    cfg = config.custom.services.piggyback;
in
{
    options.custom.services.piggyback = {
        enable = mkEnableOption "Piggyback DDNS updater";
        environmentFile = mkOption {
            type = nullOr path;
            default = null;
            example = "/run/secrets/piggyback";
            description = ''
                An environment file as defined in {manpage}`systemd.exec(5)`.
                Use this to inject secrets, e.g. database or auth credentials out of band.
            '';
        };
        user = mkOption {
            type = str;
            default = "piggyback";
            description = "User account under which the piggyback service runs.";
        };
        group = mkOption {
            type = str;
            default = "piggyback";
            description = "Group under which the piggyback service runs.";
        };
    };

    config = mkIf cfg.enable {
        users = {
            users = {
                ${cfg.user} = {
                    isSystemUser = true;
                    group = cfg.group;
                };
            };
            groups = {
                ${cfg.group} = { };
            };
        };

        systemd = {
            services.piggyback = {
                description = "Piggyback DDNS updater";
                serviceConfig = {
                    Type = "oneshot";
                    ExecStart = getExe inputs.piggyback.defaultPackage.${system};
                    EnvironmentFile = cfg.environmentFile;
                    User = cfg.user;
                    Group = cfg.group;
                };
            };
            timers.piggyback = {
                description = "Run Piggyback every 15 minutes";
                wantedBy = [ "timers.target" ];
                timerConfig = {
                    OnBootSec = "1min";
                    OnUnitActiveSec = "15min";
                    AccuracySec = "1min";
                };
            };
        };
    };
}
