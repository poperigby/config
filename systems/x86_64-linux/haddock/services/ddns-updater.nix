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
    users.ddns_updater = {
      group = "ddns_updater";
      isSystemUser = true;
    };
    groups.ddns_updater = { };
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
                "api_key": "${config.sops.placeholder."haddock/ddns_updater/porkbun_api_key"}",
                "secret_api_key": "${config.sops.placeholder."haddock/ddns_updater/porkbun_api_secret_key"}"
              }
            ]
          }
        '';
      owner = "ddns_updater";
    };
    secrets = {
      "haddock/ddns_updater/porkbun_api_key".owner = "ddns_updater";
      "haddock/ddns_updater/porkbun_api_secret_key".owner = "ddns_updater";
    };
  };
}
