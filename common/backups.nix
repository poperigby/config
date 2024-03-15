{ config, lib, ... }:

let
  cfg = config.common.backups;
  hostName = config.networking.hostName;
in
{
    # Setup common.backups options
    options.common.backups = {
        enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
        };
        paths = lib.mkOption {
            type = lib.types.listOf lib.types.str;
        };
        frequency = lib.mkOption {
            type = lib.types.str;
            default = "daily";
        };
    };

    # Only enable backups if `common.backups.enable` is true
    config = lib.mkIf cfg.enable {
        # Setup sops-nix secrets
        # The correct secrets will automatically be used based on the hostname
        sops.secrets = {
            "${hostName}/restic/url" = {};
            "${hostName}/restic/password" = {};
        };

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
    };
}
