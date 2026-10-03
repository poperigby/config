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

            systemd.services.upsmon = {
                wants = [ "network-online.target" ];
                after = [ "network-online.target" ];
            };

            sops.secrets."common/ups/password" = {
                restartUnits = [ "upsmon.service" ];
            };
        };
}
