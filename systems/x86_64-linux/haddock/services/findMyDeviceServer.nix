{ config, ... }:

let
  cfg = config.custom.services.findMyDeviceServer;
  port = 8081;
in
{
  custom.services.findMyDeviceServer = {
    enable = true;
    settings = { };
    configFile = config.sops.templates."find-my-device-server-config".path;
  };

  services.caddy.virtualHosts."devices.haddock.cc".extraConfig = ''
    reverse_proxy :${toString port}
  '';

  sops = {
    templates."find-my-device-server-config" = {
      content = # yaml
        ''
          RegistrationToken: ${config.sops.placeholder."haddock/find_my_device_server/registration_token"}
          PortInsecure: ${toString port}
          UserIdLength: 5
          MaxSavedLoc: 1000
          MaxSavedPic: 10
        '';
      owner = cfg.user;
    };
    secrets."haddock/find_my_device_server/registration_token".owner = cfg.user;
  };
}
