{ config, lib, ... }:

let
  cfg = config.poperigby.services.backups;
  hostName = config.networking.hostName;
  mail = config.poperigby.services.postfix.enable;
in
{
    options.poperigby.services.backups = {
        enable = lib.mkEnableOption "Enables Restic backups";
        paths = lib.mkOption {
            type = lib.types.listOf lib.types.str;
        };
        frequency = lib.mkOption {
            type = lib.types.str;
            default = "daily";
        };
    };

    config = lib.mkIf cfg.enable {
        services.restic.backups = {
            borgbase = {
                repositoryFile = config.sops.secrets."${hostName}/restic/url".path;
                passwordFile = config.sops.secrets."${hostName}/restic/password".path;
                # Create the repository if it doesn't exist
                initialize = true;
                pruneOpts = [
                    "--keep-daily 7"
                    "--keep-weekly 4"
                    "--keep-monthly 3"
                    "--keep-yearly 1"
                ];
                paths = cfg.paths;
                timerConfig.OnCalendar = cfg.frequency;
            };
        };

        # Notify via email when a backup fails
        systemd.services.restic-backups-borgbase.unitConfig.OnFailure = lib.mkIf mail "notify-failure-email@%i";

        # The correct secrets will automatically be used based on the hostname
        sops.secrets = {
            "${hostName}/restic/url" = {};
            "${hostName}/restic/password" = {};
        };
    };
}
