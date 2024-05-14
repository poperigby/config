{ config, lib, ... }:

let
  cfg = config.poperigby.services.backups;
  hostName = config.networking.hostName;
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

    # Only enable backups if `common.os.backups.enable` is true
    config = lib.mkIf cfg.enable {
        services.restic.backups = {
            borgbase = {
                repositoryFile = config.sops.secrets."${hostName}/restic/url".path;
                passwordFile = config.sops.secrets."${hostName}/restic/password".path;
                timerConfig.OnCalendar = cfg.frequency;
                pruneOpts = [
                    "--keep-daily 7"
                    "--keep-weekly 4"
                    "--keep-monthly 3"
                    "--keep-yearly 1"
                ];
                paths = cfg.paths;
            };
        };

        # Setup sops-nix secrets
        # The correct secrets will automatically be used based on the hostname
        sops.secrets = {
            "${hostName}/restic/url" = {};
            "${hostName}/restic/password" = {};
        };
    };
}
