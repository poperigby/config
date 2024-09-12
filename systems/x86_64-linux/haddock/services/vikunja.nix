{ config, lib, ... }:

let
    cfg = config.services.vikunja;
    domain = "tasks.haddock.cc";
in
{
    services = {
        vikunja = {
            enable = true;
            frontendScheme = "https";
            frontendHostname = domain;
            database = {
                type = "postgres";
                host = "127.0.0.1:5432";
            };
        };
        caddy.virtualHosts.${domain}.extraConfig = ''
            import auth
            reverse_proxy :3456
        '';
        authelia.instances.haddock.settings.access_control.rules = [
            {
                # Required to use the Vikunja mobile app
                domain = "tasks.haddock.cc";
                policy = "bypass";
                resources = [ "/api.*" ];
            }
        ];
    };

    # We need to do this because Vikunja doesn't support setting OpenID secrets with environment variables
    # https://kolaente.dev/vikunja/vikunja/issues/881
    environment.etc."vikunja/config.yaml".source = lib.mkForce config.sops.templates.vikunja-config.path;
    sops.templates.vikunja-config = {
        content = # yaml
        ''
            service:
                interface: ":${builtins.toString cfg.port}"
                frontendurl: "${cfg.frontendScheme}://${cfg.frontendHostname}/"
                timezone: "America/Los_Angeles"
                # Increase time until user is logged out to 3 months
                jwtttl: 7889400
            database:
                type: "${cfg.database.type}"
                host: "${cfg.database.host}"
            files:
                basepath: "/var/lib/vikunja/files"
            auth:
                local:
                    # We only want to use OIDC
                    enabled: false
                openid:
                    enabled: true
                    redirecturl: "https://${cfg.frontendHostname}/auth/openid/"
                    providers:
                      - name: "Authelia"
                        authurl: "https://auth.haddock.cc"
                        clientid: "${config.sops.placeholder.vikunja-oidc-client-id_vikunja}"
                        clientsecret: "${config.sops.placeholder.vikunja-oidc-client-secret_vikunja}"
        '';
        owner = "vikunja";
    };


    systemd.services.vikunja = let
        dependencies = [
            "postgresql.service"
        ];
    in {
        after = dependencies;
        requires = dependencies;
        # DynamicUser screws up sops-nix ownership
        serviceConfig.DynamicUser = lib.mkForce false;
    };

    users = {
        users.vikunja = {
            isSystemUser = true;
            group = "vikunja";
        };
        groups.vikunja = {};
    };

    sops.secrets = {
        vikunja-oidc-client-id_vikunja = {
            key = "haddock/vikunja/oidc_client_id";
            owner = "vikunja";
        };
        vikunja-oidc-client-secret_vikunja = {
            key = "haddock/vikunja/oidc_client_secret";
            owner = "vikunja";
        };
        vikunja-oidc-client-id_authelia = {
            key = "haddock/vikunja/oidc_client_id";
            owner = "authelia-haddock";
        };
        vikunja-oidc-client-secret_authelia = {
            key = "haddock/vikunja/oidc_client_secret";
            owner = "authelia-haddock";
        };
    };
}
