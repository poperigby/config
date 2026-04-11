{
    config,
    lib,
    pkgs,
    ...
}:
let
    user = "findmydevice";
    group = "findmydevice";
    port = 8081;
in
{
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
                    "${lib.getExe pkgs.custom.find-my-device-server} serve -c ${
                        config.sops.templates."find-my-device-server-config".path
                    } -d ${db} -w ${web}";
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

    services.caddy.virtualHosts."devices.haddock.cc".extraConfig = ''
        reverse_proxy :${toString port}
    '';

    sops = {
        templates."find-my-device-server-config" = {
            content = ''
                RegistrationToken: ${config.sops.placeholder."haddock/find_my_device_server/registration_token"}
                PortInsecure: ${toString port}
                UserIdLength: 5
                MaxSavedLoc: 1000
                MaxSavedPic: 10
            '';
            owner = user;
        };
        secrets."haddock/find_my_device_server/registration_token".owner = user;
    };
}
