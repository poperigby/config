{ config, lib, ... }:

let
    cfg = config.services.mealie;
in
{
    services = {
        mealie = {
            enable = true;
            # credentialsFile = config.sops.templates.mealie-secrets.path;
            settings = {
                ALLOW_SIGNUP = "false";
                MAX_WORKERS = "1";
                WEB_CONCURRENCY = "1";
                BASE_URL = "https://food.haddock.cc";
                # OIDC settings
            };
        };
        caddy.virtualHosts."food.haddock.cc".extraConfig = ''
            # Mealie apps break with Authelia sitting in front of them
            # import auth
            reverse_proxy :${cfg.port}
        '';
    };

    systemd.services.mealie.unitConfig.BindsTo = [ "authelia-haddock.service" ];

    # Setup a user and group for Mealie
    # users = {
    #     users.mealie = {
    #         group = "mealie";
    #         isSystemUser = true;
    #     };
    #     groups.mealie = {};
    # };


    # sops = {
    #     templates.mealie-secrets = {
    #         owner = "mealie";
    #         content = ''
    #         '';
    #     };
    #     secrets = {
    #     };
    # };
}
