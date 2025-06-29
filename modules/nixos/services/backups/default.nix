{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    getExe
    getExe'
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    ;

  inherit (lib.types)
    bool
    listOf
    str
    submodule
    ;

  cfg = config.custom.services.backups;
  hostName = config.networking.hostName;
  mail = config.custom.services.postfix.enable;
in
{
  options.custom.services.backups = {
    enable = mkEnableOption "Restic backups";
    repositories = mkOption {
      default = {
        borgbase = true;
      };
      type = submodule {
        options = {
          borgbase = mkOption {
            type = bool;
            default = true;
            description = "Enable BorgBase";
          };
          tintin = mkEnableOption "Tintin";
        };
      };
    };
    paths = mkOption {
      type = listOf str;
    };
    exclude = mkOption {
      type = listOf str;
      default = [ ];
    };
    frequency = mkOption {
      type = str;
      default = "daily";
    };
  };

  config =
    let
      systemdConfig = {
        unitConfig.OnFailure = mkIf mail "notify-failure-email@%i";

        # Run backup in a separate mount namespace so we can mount
        # a snapshot to the correct location
        # serviceConfig.PrivateMounts = true;
      };
    in
    mkIf cfg.enable {
      services.restic.backups =
        let
          inherit (config.sops) secrets;

          btrfs = getExe pkgs.btrfs-progs;
          mount = getExe' pkgs.util-linux "mount";
          umount = getExe' pkgs.util-linux "umount";

          mkRepoCfg = name: {
            repositoryFile = secrets."${hostName}/restic/${name}/url".path;
            passwordFile = secrets."${hostName}/restic/${name}/password".path;
            initialize = true;
            pruneOpts = [
              "--keep-daily 7"
              "--keep-weekly 4"
              "--keep-monthly 3"
              "--keep-yearly 1"
            ];
            backupPrepareCommand = # bash
              ''
                # TODO: Dump PostgreSQL databases

                # TODO: Create snapshot of @home and @var_lib (if it exists)

              '';
            paths = cfg.paths;
            exclude = cfg.exclude;
            timerConfig.OnCalendar = cfg.frequency;
          };
        in
        {
          borgbase = mkIf cfg.repositories.borgbase (mkRepoCfg "borgbase");
          tintin = mkIf cfg.repositories.tintin (mkRepoCfg "tintin");
        };

      systemd.services.restic-backups-borgbase = systemdConfig;
      systemd.services.restic-backups-tintin = systemdConfig;

      # The correct secrets will automatically be used based on the hostname
      sops.secrets = mkMerge [
        (mkIf cfg.repositories.borgbase {
          "${hostName}/restic/borgbase/url" = { };
          "${hostName}/restic/borgbase/password" = { };
        })
        (mkIf cfg.repositories.tintin {
          "${hostName}/restic/tintin/url" = { };
          "${hostName}/restic/tintin/password" = { };
        })
      ];
    };
}
