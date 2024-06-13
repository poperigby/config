{ config, inputs, system, ... }:

{
    imports = [ "${inputs.authelia}/nixos/modules/services/security/authelia.nix" ];
    disabledModules = [ "${inputs.nixpkgs}/nixos/modules/services/security/authelia.nix" ];

    services = {
        authelia.instances.haddock = {
            enable = true;
            package = inputs.authelia.legacyPackages.${system}.authelia;
            settings = {
                theme = "auto";
                authentication_backend.ldap = {
                    address = "ldap://localhost:3890";
                    base_dn = "dc=haddock,dc=cc";
                    users_filter = "(&({username_attribute}={input})(objectClass=person))";
                    groups_filter = "(member={dn})";
                    user = "uid=authelia,ou=people,dc=haddock,dc=cc";
                };
                access_control = {
                    default_policy = "deny";
                    rules = [
                        {
                            domain = "*.haddock.cc";
                            policy = "one_factor";
                        }
                    ];
                };
                storage.postgres = {
                   address = "unix:///run/postgresql";
                   database = "authelia-haddock";
                   username = "authelia-haddock";
                   # I'm using peer authentication, so this doesn't actually matter, but Authelia
                   # complains if I don't have it.
                   password = "authelia-haddock";
                };
                session = {
                    cookies = [
                        {
                            domain = "haddock.cc";
                            authelia_url = "https://auth.haddock.cc";
                        }
                    ];
                };
                notifier.smtp = {
                    address = "smtp://smtp.sendgrid.net:587";
                    username = "apikey";
                    sender = "admin@haddock.cc";
                };
                identity_providers.oidc = {
                    # jwks is set in jwks.yml
                    authorization_policies.default = {
                        default_policy = "one_factor";
                        rules = [
                            {
                                policy = "deny";
                                subject = "group:lldap_strict_readonly";
                            }
                        ];
                    };
                };
                # Necessary for Caddy integration
                # https://www.authelia.com/integration/proxies/caddy/#implementation
                server.endpoints.authz.forward-auth.implementation = "ForwardAuth";
            };
            # The template doesn't work correctly when parsed from Nix, so our JWKS is defined here
            settingsFiles = [ ./jwks.yml ];
            secrets = with config.sops; {
                jwtSecretFile = secrets."haddock/authelia/jwt_secret".path;
                oidcHmacSecretFile = secrets."haddock/authelia/hmac_secret".path;
                sessionSecretFile = secrets."haddock/authelia/session_secret".path;
                storageEncryptionKeyFile = secrets."haddock/authelia/storage_encryption_key".path;
            };
            environmentVariables = with config.sops; {
                AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE = secrets."haddock/authelia/lldap_authelia_password".path;
                AUTHELIA_NOTIFIER_SMTP_PASSWORD_FILE = secrets.sendgrid-api-key-authelia.path;
            };
        };
        caddy.virtualHosts."auth.haddock.cc".extraConfig = ''
            reverse_proxy :9091
        '';
    };

    systemd.services.authelia-haddock = {
        # Required for templating
        serviceConfig.Environment = "X_AUTHELIA_CONFIG_FILTERS=template";
        # Authelia requires LLDAP and PostgreSQL to be running
        unitConfig.BindsTo = [
            "lldap.service"
            "postgresql.service"
        ];
    };

    sops.secrets = {
        "haddock/authelia/hmac_secret".owner = "authelia-haddock";
        "haddock/authelia/jwks".owner = "authelia-haddock";
        "haddock/authelia/jwt_secret".owner = "authelia-haddock";
        "haddock/authelia/session_secret".owner = "authelia-haddock";
        "haddock/authelia/storage_encryption_key".owner = "authelia-haddock";
        # The password for the `authelia` user
        "haddock/authelia/lldap_authelia_password".owner = "authelia-haddock";
        sendgrid-api-key-authelia = {
            owner = "authelia-haddock";
            key = "common/sendgrid/api_key";
        };
    };

}
