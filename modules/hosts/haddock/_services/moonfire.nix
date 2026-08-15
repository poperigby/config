{ lib, pkgs, ... }:
let
    inherit (lib.local.caddy) authReverseProxy;

    user = "moonfire";
    group = "moonfire";
    port = 1024;
    format = pkgs.formats.toml { };
    settings = {
        binds = [
            {
                ipv4 = "0.0.0.0:${toString port}";
                allowUnauthenticatedPermissions.viewVideo = true;
            }
            {
                unix = "/var/lib/moonfire-nvr/sock";
                ownUidIsPrivileged = true;
            }
        ];
    };
in
{
    users = {
        users.${user} = {
            isSystemUser = true;
            group = group;
        };
        groups.${group} = { };
    };

    systemd.services.moonfire-nvr = {
        description = "Moonfire NVR";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];

        environment = {
            MOONFIRE_FORMAT = "systemd";
            MOONFIRE_LOG = "info";
        };

        serviceConfig = {
            ExecStartPre = "${lib.getExe pkgs.moonfire-nvr} init";
            ExecStart = "${lib.getExe pkgs.moonfire-nvr} run --config ${format.generate "config.toml" settings}";
            Type = "notify";
            TimeoutStartSec = 300;
            Restart = "on-failure";
            User = user;
            Group = group;
            StateDirectory = "moonfire-nvr";
            CPUAccounting = true;
            MemoryAccounting = true;
            BlockIOAccounting = true;
        };
    };

    environment.systemPackages = [ pkgs.moonfire-nvr ];

    services.caddy.virtualHosts."cctv.haddock.cc".extraConfig = authReverseProxy port;
}
