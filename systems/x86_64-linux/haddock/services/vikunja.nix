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
            settings = {
                service = {
                    interface = ":${toString cfg.port}";
                    publicurl = "${cfg.frontendScheme}://${cfg.frontendHostname}/";
                    timezone = "America/Los_Angeles";
                    # Increase time until user is logged out to 3 months
                    jwtttl = 7889400;
                };
                files = {
                    basepath = "/var/lib/vikunja/files";
                };
                auth = {
                    # We only want to use OIDC
                    local.enabled = false;
                    openid = {
                        enabled = true;
                        providers.authelia = {
                            name = "Authelia";
                            authurl = "https://auth.haddock.cc";
                            clientid.file = config.sops.secrets.vikunja-oidc-client-id_vikunja.path;
                            clientsecret.file = config.sops.secrets."haddock/vikunja/oidc_client_secret/vikunja".path;
                            scope = "openid profile email";
                        };
                    };
                };
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

    systemd.services.vikunja =
        let
            dependencies = [
                "postgresql.service"
            ];
        in
        {
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
        groups.vikunja = { };
    };

    sops.secrets = {
        vikunja-oidc-client-id_vikunja = {
            key = "haddock/vikunja/oidc_client_id";
            owner = "vikunja";
        };
        vikunja-oidc-client-id_authelia = {
            key = "haddock/vikunja/oidc_client_id";
            owner = "authelia-haddock";
        };
        "haddock/vikunja/oidc_client_secret/vikunja".owner = "vikunja";
        "haddock/vikunja/oidc_client_secret/authelia".owner = "authelia-haddock";
    };
}
