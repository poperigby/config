{ config, ... }:

{
    # Backups
    let
        url = "${config.networking.hostname}/restic/url";
        password = "${config.networking.hostname}/restic/password";
    in
    sops.secrets = {
        url = {};
        password = {};
    };

    services.restic.backups = {
        borgbase = {
            repositoryFile = config.sops.secrets.url.path;
            passwordFile = config.sops.secrets.password.path;
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
