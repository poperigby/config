{ den, ... }:
{
  den.aspects.home-services.provides.ludusavi.homeManager =
    { lib, pkgs, ... }:
    let
      settingsFormat = pkgs.formats.yaml { };
      defaultSettings = {
        manifest.url = "https://raw.githubusercontent.com/mtkennerly/ludusavi-manifest/master/data/manifest.yaml";
        roots = [ ];
        backup.path = "~/.local/state/backups/ludusavi";
        restore.path = "~/.local/state/backups/ludusavi";
      };
      configFile = settingsFormat.generate "config.yaml" defaultSettings;
    in
    {
      systemd.user = {
        services.ludusavi = {
          Unit.Description = "Run a game save backup with Ludusavi";
          Service = {
            Type = "oneshot";
            ExecStart = "${pkgs.ludusavi}/bin/ludusavi backup --force";
          };
        };
        timers.ludusavi = {
          Unit.Description = "Run a game save backup with Ludusavi, daily";
          Timer.OnCalendar = "daily";
          Install.WantedBy = [ "timers.target" ];
        };
      };

      xdg.configFile."ludusavi/config.yaml".source = lib.mkDefault configFile;

      home.packages = [ pkgs.ludusavi ];
    };

  den.aspects.home-services.provides.ludusavi-config =
    {
      configFile ? null,
      settings ? null,
    }:
    {
      homeManager =
        { pkgs, ... }:
        let
          settingsFormat = pkgs.formats.yaml { };
          defaultSettings = {
            manifest.url = "https://raw.githubusercontent.com/mtkennerly/ludusavi-manifest/master/data/manifest.yaml";
            roots = [ ];
            backup.path = "~/.local/state/backups/ludusavi";
            restore.path = "~/.local/state/backups/ludusavi";
          };
          resolvedSettings = if settings == null then defaultSettings else settings;
          resolvedConfigFile =
            if configFile == null then
              settingsFormat.generate "config.yaml" resolvedSettings
            else
              configFile;
        in
        {
          xdg.configFile."ludusavi/config.yaml".source = resolvedConfigFile;
          home.packages = [ pkgs.ludusavi ];
        };
    };
}

