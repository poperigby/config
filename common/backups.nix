{ config, lib, ... }:

{
    options = {
        enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
        };
        paths = lib.mkOption {
            type = lib.types.lines;
            default = [
                "/home/*/.local/share"
            ];
        };
    };

    # Only enable backups if this module's `enable` option is true
    config = lib.mkIf config.enable {
        # Setup sops-nix secrets
        # The correct secrets will automatically be used based on the hostname
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
                paths = config.paths;
            };
        };
    };
}
