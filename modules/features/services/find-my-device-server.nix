{ ... }:
{
    den.aspects.services.provides.find-my-device-server =
        {
            port ? 8080,
            user ? "findmydevice",
            group ? "findmydevice",
            configFile ? null,
            settings ? null,
        }:
        {
            nixos =
                { lib, pkgs, ... }:
                let
                    settingsFormat = pkgs.formats.yaml { };
                    resolvedSettings =
                        if settings == null then
                            {
                                PortInsecure = port;
                                UserIdLength = 5;
                                MaxSavedLoc = 1000;
                                MaxSavedPic = 10;
                            }
                        else
                            settings;
                    resolvedConfigFile =
                        if configFile != null then configFile else settingsFormat.generate "config.yaml" resolvedSettings;
                in
                {
                    assertions = [
                        {
                            assertion = (settings != null) || (configFile != null);
                            message = "find-my-device-server: set either `settings` or `configFile`.";
                        }
                    ];

                    users = {
                        users.${user} = {
                            isSystemUser = true;
                            group = group;
                        };
                        groups.${group} = { };
                    };

                    systemd = {
                        services.find-my-device-server = {
                            description = "FindMyDeviceServer";
                            after = [ "network.target" ];
                            wantedBy = [ "multi-user.target" ];
                            serviceConfig = {
                                ExecStart =
                                    let
                                        db = "/var/lib/findmydeviceserver/db";
                                        web = "${pkgs.custom.find-my-device-server}/share/findmydeviceserver";
                                    in
                                    "${lib.getExe pkgs.custom.find-my-device-server} serve -c ${resolvedConfigFile} -d ${db} -w ${web}";
                                User = user;
                                Group = group;
                            };
                        };
                        tmpfiles.settings."10-find-my-device-server"."/var/lib/findmydeviceserver".d = {
                            user = user;
                            group = group;
                            mode = "0755";
                        };
                    };
                };
        };
}
