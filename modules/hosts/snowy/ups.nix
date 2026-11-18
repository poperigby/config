{ ... }:
{
    den.aspects.snowy.nixos =
        { config, ... }:
        {
            power.ups = {
                enable = true;
                mode = "netclient";
                upsmon.monitor.cyberpower = {
                    system = "cyberpower@haddock";
                    user = "snowy";
                    passwordFile = config.sops.secrets."common/ups/password".path;
                    type = "secondary";
                };
            };

            # Resolve haddock without the router's DNS, so upsmon can reconnect
            # during a power outage while only the switch is on the UPS
            networking.hosts."192.168.1.184" = [ "haddock" ];

            systemd.services.upsmon = {
                wants = [ "network-online.target" ];
                after = [ "network-online.target" ];
            };

            sops.secrets."common/ups/password" = {
                restartUnits = [ "upsmon.service" ];
            };
        };
}
