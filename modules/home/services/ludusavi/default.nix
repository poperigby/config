{
    config,
    lib,
    pkgs,
    ...
}:

let
    cfg = config.custom.services.ludusavi;
    settingsFormat = pkgs.formats.yaml { };

    configFile =
        if cfg.configFile == null then
            settingsFormat.generate "config.yaml" cfg.settings
        else
            cfg.configFile;
in
{
    options.custom.services.ludusavi = {
        enable = lib.mkEnableOption "Whether to enable the Ludusavi game backup tool";
        configFile = lib.mkOption {
            type = with lib.types; nullOr path;
            default = null;
            description = lib.mdDoc ''
                Path to a Ludusavi `config.yaml`. Mutually exclusive with the `settings` option.
                See https://github.com/mtkennerly/ludusavi#configuration-file for available options.

            '';
        };
        settings = lib.mkOption {
            type = settingsFormat.type;
            default = {
                manifest.url = "https://raw.githubusercontent.com/mtkennerly/ludusavi-manifest/master/data/manifest.yaml";
                roots = [ ];
                backup.path = "~/.local/state/backups/ludusavi";
                restore.path = "~/.local/state/backups/ludusavi";
            };
            example = {
                language = "en-US";
                theme = "light";
                roots = [
                    {
                        path = "~/.local/share/Steam";
                        store = "steam";
                    }
                ];
                backup.path = "~/.local/state/backups/ludusavi";
                restore.path = "~/.local/state/backups/ludusavi";
            };
            description = lib.mdDoc ''
                Ludusavi configuration as an attribute set. See https://github.com/mtkennerly/ludusavi#configuration-file
                for available options.
            '';
        };
    };

    config = lib.mkIf cfg.enable {
        assertions = [
            {
                assertion = (cfg.settings != { }) != (cfg.configFile != null);
                message = "The `settings` and `configFile` options are mutually exclusive.";
            }
        ];

        systemd.user = {
            services.ludusavi = {
                Unit.Description = "Run a game save backup with Ludusavi";
                Service = {
                    Type = "oneshot";
                    ExecStart = "${pkgs.ludusavi}/bin/ludusavi backup --force";
                };
            };
            timers.ludusavi = {
                Unit.Description = "Run a game save backup with Ludusavi, daily";
                Timer.OnCalendar = "daily";
                Install.WantedBy = [ "timers.target" ];
            };
        };

        xdg.configFile."ludusavi/config.yaml".source = configFile;

        home.packages = [ pkgs.ludusavi ];
    };
}
