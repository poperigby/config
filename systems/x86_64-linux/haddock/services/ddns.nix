{ config, ... }:

{
    # Synchronizes Haddock's public IP with Porkbun
    custom.services.piggyback = {
        enable = true;
        environmentFile = config.sops.templates.ddns-config.path;
    };

    sops = {
        templates.ddns-config = {
            content = # bash
                ''
                    PORKBUN_DOMAIN=haddock.cc
                    PORKBUN_API_KEY=${config.sops.placeholder."haddock/ddns/porkbun_api_key"}
                    PORKBUN_SECRET_API_KEY=${config.sops.placeholder."haddock/ddns/porkbun_api_secret_key"}
                '';
            owner = "piggyback";
        };
        secrets = {
            "haddock/ddns/porkbun_api_key".owner = "piggyback";
            "haddock/ddns/porkbun_api_secret_key".owner = "piggyback";
        };
    };
}
