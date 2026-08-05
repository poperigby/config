{
    config,
    lib,
    privateInfo,
    ...
}:

let
    inherit (lib) mkAfter mkOption types;

    authelia = "authelia-haddock";
in
{
    options.services.authelia.oidcClients = mkOption {
        type = types.attrsOf (types.listOf (types.attrsOf types.anything));
        default = { };
        description = "OpenID Connect clients for each Authelia instance, configured in the service modules that use them.";
    };

    config = {
        services = {
            caddy = {
                virtualHosts."auth.haddock.cc".extraConfig = ''
                    reverse_proxy :9091
                '';
                # A snippet that can be imported to enable Authelia in front of a service
                # https://www.authelia.com/integration/proxies/caddy/#subdomain
                extraConfig = ''
                    (auth) {
                        forward_auth :9091 {
                            uri /api/authz/forward-auth
                            copy_headers Remote-User Remote-Groups Remote-Email Remote-Name
                        }
                    }
                '';
            };
            authelia = {
                instances.haddock = {
                    enable = true;
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
                            # We want this rule to be low priority so it doesn't override the others
                            rules = mkAfter [
                                {
                                    domain = "*.haddock.cc";
                                    policy = "one_factor";
                                }
                            ];
                        };
                        storage.postgres = {
                            address = "unix:///run/postgresql";
                            database = authelia;
                            username = authelia;
                        };
                        session = {
                            redis.host = "/var/run/redis-haddock/redis.sock";
                            cookies = [
                                {
                                    domain = "haddock.cc";
                                    authelia_url = "https://auth.haddock.cc";
                                    # The period of time the user can be inactive for before the session is destroyed
                                    inactivity = "1M";
                                    # The period of time before the cookie expires and the session is destroyed
                                    expiration = "3M";
                                    # The period of time before the cookie expires and the session is destroyed
                                    # when the remember me box is checked
                                    remember_me = "1y";
                                }
                            ];
                        };
                        notifier.smtp = {
                            address = "smtp://smtp.mailbox.org:587";
                            username = privateInfo.poperigby.email;
                            sender = "haddock@mailbox.org";
                        };
                        log.level = "info";
                        identity_providers.oidc = {
                            # https://www.authelia.com/integration/openid-connect/openid-connect-1.0-claims/#restore-functionality-prior-to-claims-parameter
                            claims_policies = {
                                opkssh.id_token = [ "email" ];

                            };
                            cors = {
                                endpoints = [ "token" ];
                                allowed_origins_from_client_redirect_uris = true;
                            };
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
                        webauthn.enable_passkey_login = true;
                        # https://www.authelia.com/integration/proxies/caddy/#implementation
                        server.endpoints.authz.forward-auth.implementation = "ForwardAuth";
                    };
                    settingsFiles = [ config.sops.templates.authelia-oidc-clients.path ];
                    secrets = with config.sops; {
                        jwtSecretFile = secrets."haddock/authelia/jwt_secret".path;
                        oidcIssuerPrivateKeyFile = secrets."haddock/authelia/jwks".path;
                        oidcHmacSecretFile = secrets."haddock/authelia/hmac_secret".path;
                        sessionSecretFile = secrets."haddock/authelia/session_secret".path;
                        storageEncryptionKeyFile = secrets."haddock/authelia/storage_encryption_key".path;
                    };
                    environmentVariables = with config.sops; {
                        AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE =
                            secrets."haddock/authelia/lldap_authelia_password".path;
                        AUTHELIA_NOTIFIER_SMTP_PASSWORD_FILE = secrets.smtp-password_authelia.path;
                    };
                };

                # https://github.com/openpubkey/opkssh/blob/main/docs/CONFIGURATION.md
                oidcClients.haddock = [
                    {
                        client_name = "OPKSSH";
                        client_id = "opkssh";
                        public = true;
                        authorization_policy = "one_factor";
                        claims_policy = "opkssh";
                        require_pkce = true;
                        pkce_challenge_method = "S256";
                        redirect_uris = [
                            "http://localhost:3000/login-callback"
                            "http://localhost:10001/login-callback"
                            "http://localhost:11110/login-callback"
                        ];
                        scopes = [
                            "openid"
                            "offline_access"
                        ];
                        response_types = [ "code" ];
                        grant_types = [
                            "authorization_code"
                            "refresh_token"
                        ];
                        access_token_signed_response_alg = "none";
                        userinfo_signed_response_alg = "none";
                        token_endpoint_auth_method = "none";
                    }
                ];
            };
        };

        # Give Authelia access to the Redis socket
        users.users.${authelia}.extraGroups = [ "redis-haddock" ];

        systemd.services.${authelia} =
            let
                dependencies = [
                    "lldap.service"
                    "postgresql.service"
                    "redis-haddock.service"
                ];

            in
            {
                # Authelia requires LLDAP, PostgreSQL, and Redis to be running
                after = dependencies;
                requires = dependencies;
            };

        sops = {
            templates.authelia-oidc-clients = {
                owner = authelia;
                content = builtins.toJSON {
                    identity_providers.oidc.clients = config.services.authelia.oidcClients.haddock;
                };
                restartUnits = [ "${authelia}.service" ];
            };
            secrets = {
                "haddock/authelia/hmac_secret".owner = authelia;
                "haddock/authelia/jwks".owner = authelia;
                "haddock/authelia/jwt_secret".owner = authelia;
                "haddock/authelia/session_secret".owner = authelia;
                "haddock/authelia/storage_encryption_key".owner = authelia;
                # The password for the `authelia` LLDAP user
                "haddock/authelia/lldap_authelia_password".owner = authelia;
                smtp-password_authelia = {
                    owner = authelia;
                    key = "common/users/cassidy/email/password";
                };
            };
        };
    };

}
