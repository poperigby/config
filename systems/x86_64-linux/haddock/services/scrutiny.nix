{ config, lib, ... }:

let
    cfg = config.services.scrutiny;
in
{
    services = {
        scrutiny = {
            enable = true;
            settings = {
                web.listen.port = 8082;
            };
            collector = {
                # Why is this disabled by default?
                enable = true;
            };
        };
        caddy.virtualHosts."drives.haddock.cc".extraConfig = ''
            import auth
            reverse_proxy :${builtins.toString cfg.settings.web.listen.port}
        '';
    };

    systemd.services.scrutiny.serviceConfig = {
        # DynamicUser screws up sops-nix ownership
        DynamicUser = lib.mkForce false;
        EnvironmentFile = config.sops.templates.scrutiny-secrets.path;
    };

    # Setup a user and group for Scrutiny
    users = {
        users.scrutiny = {
            group = "scrutiny";
            isSystemUser = true;
        };
        groups.scrutiny = {};
    };

    sops = {
        templates.scrutiny-secrets = {
            content = with config.sops.placeholder; ''
                SCRUTINY_NOTIFY_URLS="smtp://apikey:${sendgrid-api-key_scrutiny}@smtp.sendgrid.net:587/?from=admin@haddock.cc&to=poperigby@mailbox.org"
            '';
            owner = "scrutiny";
        };
        secrets = {
            sendgrid-api-key_scrutiny = {
                key = "common/sendgrid/api_key";
                owner = "scrutiny";
            };
        };
    };
}
