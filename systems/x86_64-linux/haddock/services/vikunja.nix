{ config, lib, ... }:

let
    cfg = config.services.vikunja;
in
{
    services.vikunja = {
        enable = true;
        frontendScheme = "https";
        frontendHostname = "tasks.haddock.cc";
        database = {
            type = "postgres";
            host = "127.0.0.1:5432";
        };
    };

    # We need to do this because Vikunja doesn't support setting OpenID secrets with environment variables
    # https://kolaente.dev/vikunja/vikunja/issues/881
    environment.etc."vikunja/config.yaml".source = lib.mkForce config.sops.templates.vikunja-config.path;

    services.caddy.virtualHosts."tasks.haddock.cc".extraConfig = ''
        import auth
        reverse_proxy :3456
    '';

    systemd.services.vikunja.serviceConfig.DynamicUser = lib.mkForce false;

    users = {
        users.vikunja = {
            isSystemUser = true;
            group = "vikunja";
        };
        groups.vikunja = {};
    };

    sops = {
        templates.vikunja-config = {
            content = # yaml
            ''
                service:
                    interface: ":${builtins.toString cfg.port}"
                    frontendurl: "${cfg.frontendScheme}://${cfg.frontendHostname}/"
                database:
                    type: "${cfg.database.type}"
                    host: "${cfg.database.host}"
                files:
                    basepath: "/var/lib/vikunja/files"
                auth:
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
        secrets = {
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
    };
}
