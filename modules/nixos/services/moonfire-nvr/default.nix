{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    getExe
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    ;

  inherit (lib.types)
    attrsOf
    nullOr
    port
    str
    ;

  cfg = config.custom.services.moonfire-nvr;

  format = pkgs.formats.toml { };
in
{
  options.custom.services.moonfire-nvr = {
    enable = mkEnableOption "Moonfire NVR service";
    package = mkPackageOption pkgs.custom "moonfire-nvr" { };
    settings = mkOption {
      type = format.type;
      default = {
        binds = [
          {
            ipv4 = "0.0.0.0:${toString cfg.port}";
            allowUnauthenticatedPermissions = {
              viewVideo = true;
            };
          }
          {
            unix = "/var/lib/moonfire-nvr/sock";
            ownUidIsPrivileged = true;
          }
        ];
      };
      description = ''
        Moonfire NVR configuration.

        See the [documentation](https://github.com/scottlamb/moonfire-nvr/blob/master/ref/config.md) for options.
      '';
    };
    extraEnvironment = mkOption {
      type = attrsOf str;
      default = { };
      description = "Additional environment variables for Moonfire NVR.";
    };
    user = mkOption {
      type = str;
      default = "moonfire";
      description = "User under which the Moonfire NVR service runs.";
    };
    group = mkOption {
      type = str;
      default = "moonfire";
      description = "Group to run the Moonfire NVR service as.";
    };

    port = mkOption {
      type = nullOr port;
      default = 8080;
      description = ''
        The TCP port on which Moonfire NVR will listen.
        This automatically creates a suitable [[binds]] entry in the settings file.
      '';
    };
  };

  config = mkIf cfg.enable {
    users = {
      users.${cfg.user} = {
        isSystemUser = true;
        group = cfg.group;
      };
      groups.moonfire = { };
    };

    systemd.services.moonfire-nvr = {
      description = "Moonfire NVR";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      environment = {
        MOONFIRE_FORMAT = "systemd";
        MOONFIRE_LOG = "info";
      } // cfg.extraEnvironment;

      serviceConfig = {
        ExecStartPre = "${getExe cfg.package} init";
        ExecStart = "${getExe cfg.package} run --config ${format.generate "config.toml" cfg.settings}";
        Type = "notify";

        # Large installations take a while to scan the sample file directories
        TimeoutStartSec = 300;
        Restart = "on-failure";

        User = cfg.user;
        Group = cfg.group;

        StateDirectory = "moonfire-nvr";

        # Hardening options
        CPUAccounting = true;
        MemoryAccounting = true;
        BlockIOAccounting = true;
      };

    };
  };
}
