{
  lib,
  pkgs,
  config,
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
    str
    ;

  cfg = config.custom.services.filebrowser;
  format = pkgs.formats.yaml { };
  configFile = format.generate "config.yaml" cfg.settings;
in
{
  options.custom.services.filebrowser = {
    enable = mkEnableOption "FileBrowser";
    package = mkPackageOption pkgs.custom "filebrowser" { };
    settings = mkOption {
      type = format.type;
      default = { };
      description = ''
        FileBrowser configuration in YAML-compatible attribute format.
        Refer to https://github.com/gtsteffaniak/filebrowser/wiki/Configuration-And-Examples
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
      example = "/run/secrets/filebrowser";
      description = ''
        Path of a file with extra environment variables to be loaded from disk. This file is not added to the nix store, so it can be used to pass secrets to FileBrowser.

        Refer to the [documentation](https://github.com/gtsteffaniak/filebrowser/wiki/Environment-Variables) for options.
        ```
      '';
    };
    user = mkOption {
      type = str;
      default = "filebrowser";
      description = "User to run the FileBrowser service as.";
    };
    group = mkOption {
      type = str;
      default = "filebrowser";
      description = "Group to run the FileBrowser service as.";
    };
  };

  config = mkIf cfg.enable {
    users = {
      users.filebrowser = {
        isSystemUser = true;
        group = cfg.group;
      };
      groups.filebrowser = { };
    };

    systemd.services.filebrowser = {
      description = "FileBrowser Web UI";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        ExecStart = "${getExe cfg.package} -c ${configFile}";
        EnvironmentFile = mkIf (cfg.secretsFile != null) cfg.secretsFile;
        User = cfg.user;
        Group = cfg.group;
        Restart = "always";
        StateDirectory = "filebrowser";
        WorkingDirectory = "/var/lib/filebrowser/";
      };
    };
  };
}
