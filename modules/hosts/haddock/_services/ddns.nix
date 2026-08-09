{
    config,
    inputs,
    lib,
    pkgs,
    ...
}:
let
    user = "piggyback";
    group = "piggyback";
    system = pkgs.stdenv.hostPlatform.system;
in
{
    # Synchronizes Haddock's public IP with Porkbun
    users = {
        users.${user} = {
            isSystemUser = true;
            group = group;
        };
        groups.${group} = { };
    };

    systemd = {
        services.piggyback = {
            description = "Piggyback DDNS updater";
            wants = [ "network-online.target" ];
            after = [ "network-online.target" ];
            serviceConfig = {
                Type = "oneshot";
                ExecStart = lib.getExe inputs.piggyback.defaultPackage.${system};
                EnvironmentFile = config.sops.templates.ddns-config.path;
                User = user;
                Group = group;
            };
        };
        timers.piggyback = {
            description = "Run Piggyback every 15 minutes";
            wantedBy = [ "timers.target" ];
            timerConfig = {
                OnBootSec = "1min";
                OnUnitActiveSec = "15min";
                AccuracySec = "1min";
            };
        };
    };

    sops = {
        templates.ddns-config = {
            content = ''
                PORKBUN_DOMAIN=haddock.cc
                PORKBUN_API_KEY=${config.sops.placeholder."haddock/ddns/porkbun_api_key"}
                PORKBUN_SECRET_API_KEY=${config.sops.placeholder."haddock/ddns/porkbun_api_secret_key"}
            '';
            owner = user;
        };
        secrets = {
            "haddock/ddns/porkbun_api_key".owner = user;
            "haddock/ddns/porkbun_api_secret_key".owner = user;
        };
    };
}
