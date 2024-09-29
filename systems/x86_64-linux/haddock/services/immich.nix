{ config, ... }:

let
    cfg = config.services.immich;
in
{
    services = {
        immich.enable = true;
        caddy.virtualHosts."photos.haddock.cc".extraConfig = ''
            import auth
            reverse_proxy http://${cfg.host}:${toString cfg.port}
        '';
        authelia.instances.haddock.settings.access_control.rules = [
            {
                # Required to use the Immich mobile app
                domain = "photos.haddock.cc";
                policy = "bypass";
                resources = [
                   "^/.well-known/immich"
                   "^/api"
                   "^/share"
                ];
            }
        ];
    };

    sops.secrets = {
        immich-oidc-client-id_immich = {
            key = "haddock/immich/oidc_client_id";
            owner = cfg.user;
        };
        immich-oidc-client-id_authelia = {
            key = "haddock/immich/oidc_client_id";
            owner = "authelia-haddock";
        };
        "haddock/immich/oidc_client_secret/immich".owner = cfg.user;
        "haddock/immich/oidc_client_secret/authelia".owner = "authelia-haddock";
    };
}
