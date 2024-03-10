{ config, ... }:

{
    # Backups
    sops.secrets = {
        "${config.networking.hostname}/restic/url" = {};
        "${config.networking.hostname}/restic/password" = {};
    };

    services.restic.backups = {
        borgbase = {
            repositoryFile = config.sops.secrets."${config.networking.hostname}/restic/url".path;
            passwordFile = config.sops.secrets."${config.networking.hostname}/restic/password".path;
            timerConfig.OnCalendar = "daily";
            paths = [
                "/home/*/.local/share"
            ];
            pruneOpts = [
                "--keep-daily 7"
                "--keep-weekly 4"
                "--keep-monthly 3"
                "--keep-yearly 1"
            ];
        };
    };
}
