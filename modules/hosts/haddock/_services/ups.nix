{ config, ... }:
{
    power.ups = {
        enable = true;
        mode = "netserver";
        ups.cyberpower = {
            driver = "usbhid-ups";
            port = "auto";
            description = "CyberPower BRG1350AVRLCD";
            directives = [
                "vendorid = 0764"
                "productid = 0501"
            ];
        };
        upsd.listen = [ { address = "0.0.0.0"; } ];
        users = {
            haddock = {
                passwordFile = config.sops.secrets."haddock/ups/primary_password".path;
                upsmon = "primary";
            };
            snowy = {
                passwordFile = config.sops.secrets."common/ups/password".path;
                upsmon = "secondary";
            };
        };
        upsmon.monitor.cyberpower = {
            system = "cyberpower@localhost";
            user = "haddock";
            type = "primary";
        };
    };

    networking.firewall.interfaces.enp10s0.allowedTCPPorts = [ 3493 ];

    sops.secrets = {
        "haddock/ups/primary_password" = {
            restartUnits = [
                "upsd.service"
                "upsmon.service"
            ];
        };
        "common/ups/password" = {
            restartUnits = [ "upsd.service" ];
        };
    };
}
