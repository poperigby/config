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
    ;

  inherit (lib.types) nullOr path int;

  cfg = config.custom.services.findMyDeviceServer;
  settingsFormat = pkgs.formats.yaml { };

  configFile =
    if cfg.configFile == null then
      settingsFormat.generate "config.yaml" cfg.settings
    else
      cfg.configFile;
in
{
  options.custom.services.findMyDeviceServer = {
    enable = mkEnableOption "FindMyDeviceServer";
    port = mkOption {
      type = int;
      default = 8080;
    };
    configFile = mkOption {
      type = nullOr path;
      default = null;
      description = "Path to a configuration file.";
    };
    settings = mkOption {
      type = settingsFormat.type;
      default = {
        PortInsecure = cfg.port;
        UserIdLength = 5;
        MaxSavedLoc = 1000;
        MaxSavedPic = 10;
      };
      description = ''
        Configuration, as described in
        https://gitlab.com/Nulide/findmydeviceserver/-/blob/master/config.example.yml
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = (cfg.settings != { }) != (cfg.configFile != null);
        message = "The `settings` and `configFile` options are mutually exclusive.";
      }
    ];

    systemd = {
      services.find-my-device-server = {
        description = "FindMyDeviceServer";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          ExecStart = "${getExe pkgs.custom.find-my-device-server} serve --web-dir ${pkgs.custom.find-my-device-server}/share/findmydeviceserver --config ${configFile}";
          WorkingDirectory = "/var/lib/findmydeviceserver";
          User = "findmydevice";
          Group = "findmydevice";
        };
      };
      tmpfiles.settings."10-find-my-device-server"."/var/lib/findmydeviceserver".d = {
        user = "findmydevice";
        group = "findmydevice";
        mode = "0755";
      };
    };

    users = {
      users.findmydevice = {
        isSystemUser = true;
        group = "findmydevice";
      };
      groups.findmydevice = { };
    };
  };
}
