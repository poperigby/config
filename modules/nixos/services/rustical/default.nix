{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    getExe
    isString
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    ;

  inherit (lib.types)
    nullOr
    path
    port
    str
    ;

  cfg = config.custom.services.rustical;

  format = pkgs.formats.toml { };
in
{
  options.custom.services.rustical = {
    enable = mkEnableOption "Rustical service";
    package = mkPackageOption pkgs.custom "rustical" { };
    settings = mkOption {
      type = format.type;
      default = {
        data_store.sqlite.db_url = "/var/lib/rustical/db.sqlite3";
        http = {
          host = "0.0.0.0";
          port = cfg.port;
        };
        frontend = {
          enabled = true;
          allow_password_login = true;
        };
        tracing.opentelemetry = false;
        dav_push.enabled = true;
        nextcloud_login.enabled = true;
      };
      description = ''
        Configuration for Rustical, written as TOML

        Refer to the [documentation](https://lennart-k.github.io/rustical/installation/configuration) for options.
      '';
    };
    secretsFile = mkOption {
      type = nullOr (
        str
        // {
          # We don't want users to be able to pass a path literal here but
          # it should look like a path.
          check = it: isString it && path.check it;
        }
      );
      default = null;
      example = "/run/secrets/rustical";
      description = ''
        Path of a file with extra environment variables to be loaded from disk. This file is not added to the nix store, so it can be used to pass secrets to Rustical.

        Refer to the [documentation](https://lennart-k.github.io/rustical/installation/configuration/#environment-variables) for options.
      '';
    };
    port = mkOption {
      type = nullOr port;
      default = 4000;
      description = ''
        The TCP port on which Rustical will listen.
      '';
    };
    user = mkOption {
      type = str;
      default = "rustical";
      description = "User under which the rustical service runs.";
    };
    group = mkOption {
      type = str;
      default = "rustical";
      description = "Group under which the rustical service runs.";
    };
  };

  config = mkIf cfg.enable {
    users = {
      users.${cfg.user} = {
        isSystemUser = true;
        group = cfg.group;
      };
      groups.${cfg.group} = { };
    };

    systemd.services.rustical = {
      description = "Rustical Service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${getExe cfg.package} --config-file ${format.generate "config.toml" cfg.settings}";
        EnvironmentFile = mkIf (cfg.secretsFile != null) cfg.secretsFile;
        StateDirectory = "rustical";
        User = cfg.user;
        Group = cfg.group;
        Restart = "on-failure";
      };
    };
  };
}
