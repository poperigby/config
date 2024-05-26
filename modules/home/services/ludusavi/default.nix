{ config, lib, pkgs, ... }:

let
    cfg = config.poperigby.services.ludusavi;
    settingsFormat = pkgs.formats.yaml {};

    configFile = settingsFormat.generate "config.yaml" cfg.settings;
in
{
    options.poperigby.services.ludusavi = {
        enable = lib.mkEnableOption "Enable Ludusavi game backup tool";
        settings = lib.mkOption {
            type = settingsFormat.type;
            default = {
                manifest.url = "https://raw.githubusercontent.com/mtkennerly/ludusavi-manifest/master/data/manifest.yaml";
                roots = [];
                backups.path = "~/.local/share/ludusavi-backups";
                restore.path = "~/.local/share/ludusavi-backups";
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
            };
            description = ''
                Ludusavi configuration as an attribute set. See https://github.com/mtkennerly/ludusavi#configuration-file
                for available options.
            '';
        };
    };

    config = lib.mkIf cfg.enable {
        systemd.user.services.ludusavi = {
            enable = true;
            wantedBy = [ "default.target" ];
            description = "Run a game save backup with Ludusavi";
            serviceConfig = {
                Type = "simple";
                ExecStart = "${pkgs.ludusavi}/bin/ludusavi backup";
            };
        };

        xdg.configFile."ludusavi/config.yaml".source = configFile;
    };
}
