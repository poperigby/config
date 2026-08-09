{
    config,
    lib,
    pkgs,
    ...
}:

let
    domain = "files.haddock.cc";
    port = 2448;
    user = "phylum";
    dataDir = "/var/lib/phylum";
in
{
    systemd.services.phylum = {
        description = "Phylum file storage server";
        wantedBy = [ "multi-user.target" ];
        after = [
            "network-online.target"
            "postgresql.service"
        ];
        requires = [ "postgresql.service" ];
        wants = [ "network-online.target" ];

        serviceConfig = {
            User = user;
            Group = user;
            StateDirectory = "phylum";
            WorkingDirectory = dataDir;
            ExecStart = "${lib.getExe pkgs.custom.phylum} --config-file ${config.sops.templates.phylum-config.path} serve";
            Restart = "on-failure";
            RestartSec = 5;

            Environment = "HOME=${dataDir}";
            NoNewPrivileges = true;
            PrivateDevices = true;
            PrivateTmp = true;
            ProtectHome = true;
            ProtectSystem = "strict";
        };
    };

    services = {
        caddy.virtualHosts.${domain}.extraConfig = ''
            reverse_proxy :${toString port}
        '';
        authelia.oidcClients.haddock = [
            {
                client_name = "Phylum";
                client_id = user;
                client_secret = config.sops.placeholder."haddock/phylum/oidc_client_secret/authelia";
                public = false;
                authorization_policy = "one_factor";
                consent_mode = "implicit";
                require_pkce = true;
                pkce_challenge_method = "S256";
                redirect_uris = [ "https://${domain}/api/v1/auth/oauth/redirect" ];
            }
        ];
        postgresql = {
            ensureDatabases = [ user ];
            ensureUsers = [
                {
                    name = user;
                    ensureDBOwnership = true;
                }
            ];
        };
    };

    users = {
        users.${user} = {
            isSystemUser = true;
            group = user;
            home = dataDir;
        };
        groups.${user} = { };
    };

    sops = {
        templates.phylum-config = {
            owner = user;
            mode = "0400";
            restartUnits = [ "phylum.service" ];
            content = builtins.toJSON {
                server = {
                    host = "127.0.0.1";
                    inherit port;
                    webappsrc = "${pkgs.custom.phylum}/share/phylum/web";
                };
                db = {
                    host = "/run/postgresql";
                    port = 5432;
                    name = user;
                    user = user;
                };
                storage.root = "${dataDir}/storage";
                auth = {
                    password.backend = "none";
                    openid.clients.authelia = {
                        name = "Authelia";
                        issuer_url = "https://auth.haddock.cc";
                        client_id = user;
                        client_secret = config.sops.placeholder."haddock/phylum/oidc_client_secret/phylum";
                        allow_unverified_emails = false;
                        auto_create_users = true;
                    };
                };
            };
        };
        secrets = {
            "haddock/phylum/oidc_client_secret/phylum".owner = user;
            "haddock/phylum/oidc_client_secret/authelia".owner = "authelia-haddock";
        };
    };
}
