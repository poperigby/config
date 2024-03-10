{ config, ... }:

{
    # Setup sops-nix secrets
    sops.secrets = {
        "${config.networking.hostName}/restic/url" = {};
        "${config.networking.hostName}/restic/password" = {};
    };

    services.restic.backups = {
        borgbase = {
            repositoryFile = config.sops.secrets."${config.networking.hostName}/restic/url".path;
            passwordFile = config.sops.secrets."${config.networking.hostName}/restic/password".path;
            timerConfig.OnCalendar = "daily";
            pruneOpts = [
                "--keep-daily 7"
                "--keep-weekly 4"
                "--keep-monthly 3"
                "--keep-yearly 1"
            ];
            paths = [
                "/home/*/.local/share"
            ];
        };
    };
}
