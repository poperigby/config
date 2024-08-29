{ config, lib, ... }:

let
    inherit (lib)
        mkEnableOption
        mkIf
        mkOption
    ;

    inherit (lib.types) listOf str;

    cfg = config.poperigby.services.backups;
    hostName = config.networking.hostName;
    mail = config.poperigby.services.postfix.enable;
in
{
    options.poperigby.services.backups = {
        enable = mkEnableOption "Restic backups";
        paths = mkOption {
            type = listOf str;
        };
        frequency = mkOption {
            type = str;
            default = "daily";
        };
    };

    config = mkIf cfg.enable {
        services.restic.backups = let
            inherit (config.sops) secrets;

            pruneOpts = [
                "--keep-daily 7"
                "--keep-weekly 4"
                "--keep-monthly 3"
                "--keep-yearly 1"
            ];
        in {
            borgbase = {
                repositoryFile = secrets."${hostName}/restic/borgbase/url".path;
                passwordFile = secrets."${hostName}/restic/borgbase/password".path;
                # Create the repository if it doesn't exist
                initialize = true;
                pruneOpts = pruneOpts;
                paths = cfg.paths;
                timerConfig.OnCalendar = cfg.frequency;
            };
            tintin = {
                repositoryFile = secrets."${hostName}/restic/tintin/url".path;
                passwordFile = secrets."${hostName}/restic/tintin/password".path;
                initialize = true;
                pruneOpts = pruneOpts;
                paths = cfg.paths;
                timerConfig.OnCalendar = cfg.frequency;
            };
        };

        # Notify via email when a backup fails
        systemd.services.restic-backups-borgbase.unitConfig.OnFailure = mkIf mail "notify-failure-email@%i";
        systemd.services.restic-backups-tintin.unitConfig.OnFailure = mkIf mail "notify-failure-email@%i";

        # The correct secrets will automatically be used based on the hostname
        sops.secrets = {
            "${hostName}/restic/borgbase/url" = {};
            "${hostName}/restic/borgbase/password" = {};
            "${hostName}/restic/tintin/url" = {};
            "${hostName}/restic/tintin/password" = {};
        };
    };
}
