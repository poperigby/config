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
      btrfs = getExe pkgs.btrfs-progs;
      grep = getExe pkgs.ripgrep;
      mount = getExe' pkgs.util-linux "mount";
      umount = getExe' pkgs.util-linux "umount";

      mkRepoCfg = name: {
        services.restic.backups.${name} = {
          repositoryFile = config.sops.secrets."${hostName}/restic/${name}/url".path;
          passwordFile = config.sops.secrets."${hostName}/restic/${name}/password".path;
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

              # Clean up old snapshots if necessary
              deleted_any=false
              if ${btrfs} subvolume delete /.snapshots/@restic-home 2>/dev/null; then deleted_any=true; fi
              if ${btrfs} subvolume delete /.snapshots/@restic-var_lib 2> /dev/null; then deleted_any=true; fi
              if $deleted_any; then
                  echo "WARNING: Previous run did not cleanly finish, removing old snapshot(s)"
              fi

              # Create snapshots and bind mount them to their correct locations under /, so everything will appear normal to Restic
              # We're running in a private mount namespace, so remounting things is safe
              ${btrfs} subvolume snapshot -r /home /.snapshots/@restic-home
              ${umount} /home
              ${mount} --bind /.snapshots/@restic-home /home

              if ${btrfs} subvolume list / | ${grep} -q "@var_lib"; then
                  ${btrfs} subvolume snapshot -r /var/lib /.snapshots/@restic-var_lib
                  ${umount} /var/lib
                  ${mount} --bind /.snapshots/@restic-var_lib /var/lib
              fi

            '';
          backupCleanupCommand = # bash
            ''
              ${btrfs} subvolume delete /.snapshots/@restic-home || true
              ${btrfs} subvolume delete /.snapshots/@restic-var_lib || true
            '';
          paths = cfg.paths;
          exclude = cfg.exclude;
          timerConfig.OnCalendar = cfg.frequency;
        };

        systemd.services."restic-backups-${name}" = {
          unitConfig.OnFailure = mkIf mail "notify-failure-email@%i";

          # Run backup in a separate mount namespace so we can mount
          # a snapshot to the correct location
          serviceConfig.PrivateMounts = true;
        };

        # The correct secrets will automatically be used based on the hostname
        sops.secrets = {
          "${hostName}/restic/${name}/url" = { };
          "${hostName}/restic/${name}/password" = { };
        };
      };
    in
    mkIf cfg.enable (mkMerge [
      (mkIf cfg.repositories.borgbase (mkRepoCfg "borgbase"))
      (mkIf cfg.repositories.tintin (mkRepoCfg "tintin"))
    ]);
}
