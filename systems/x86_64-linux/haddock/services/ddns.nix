{ config, lib, ... }:

let
  inherit (lib) mkForce;
in
{
  # Synchronizes Haddock's public IP with Porkbun
  services = {
    ddns-updater = {
      enable = true;
      environment = {
        CONFIG_FILEPATH = config.sops.templates.ddns-updater-config.path;
        LOG_LEVEL = "debug";
      };
    };
    caddy.virtualHosts."ddns.haddock.cc".extraConfig = ''
      import auth
      reverse_proxy :8000
    '';
  };

  systemd.services.ddns-updater.serviceConfig.DynamicUser = mkForce false;

  users = {
    users.ddns = {
      group = "ddns";
      isSystemUser = true;
    };
    groups.ddns = { };
  };

  sops = {
    templates.ddns-updater-config = {
      content = # json
        ''
          {
            "settings": [
              {
                "provider": "porkbun",
                "domain": "haddock.cc",
                "api_key": "${config.sops.placeholder."haddock/ddns/porkbun_api_key"}",
                "secret_api_key": "${config.sops.placeholder."haddock/ddns/porkbun_api_secret_key"}"
              }
            ]
          }
        '';
      owner = "ddns";
    };
    secrets = {
      "haddock/ddns/porkbun_api_key".owner = "ddns";
      "haddock/ddns/porkbun_api_secret_key".owner = "ddns";
    };
  };
}
