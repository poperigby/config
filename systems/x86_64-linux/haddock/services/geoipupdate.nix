{ config, lib, ... }:

{
    services.geoipupdate = {
        enable = true;
        settings = {
            AccountID = 1038010;
            LicenseKey = config.sops.secrets."haddock/max_mind/license_key".path;
            EditionIDs = [
                "GeoLite2-ASN"
                "GeoLite2-City"
                "GeoLite2-Country"
            ];
        };
    };

    users = {
        users.geoip = {
            group = "geoip";
            isSystemUser = true;
        };
        groups.geoip = {};
    };

    systemd.services.geoipupdate.serviceConfig.DynamicUser = lib.mkForce false;

    sops.secrets."haddock/max_mind/license_key".owner = "geoip";
}
