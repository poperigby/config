{ config, ... }:

let
    lldap = config.services.lldap;
in
{
    services = {
        radicale = {
            enable = true;
            settings.auth = {
                type = "ldap";
                ldap_uri = "ldap://localhost:${toString lldap.settings.ldap_port}";
                ldap_base = "dc=haddock,dc=cc";
                ldap_reader_dn = "uid=radicale,ou=people,dc=haddock,dc=cc";
                ldap_filter = "(&(objectClass=person)(uid={0}))";
                lc_username = true;
            };
        };
        caddy.virtualHosts."dav.haddock.cc".extraConfig = ''
            redir / /radicale/
            handle_path /radicale/* {
                reverse_proxy :5232 {
                    header_up X-Script-Name /radicale
                }
            }
        '';
    };

    sops = {
        templates.radicale-secrets = {
            content = # bash
            ''
                RADICALE_OPTIONS="--auth-ldap-secret=${config.sops.placeholder."haddock/radicale/ldap_secret"}"
            '';
            owner = "radicale";
        };
        secrets."haddock/radicale/ldap_secret".owner = "radicale";
    };

    systemd.services.radicale = let
       dependencies = [ "lldap.service" ];
    in {
        after = dependencies;
        requires = dependencies;
        serviceConfig.EnvironmentFile = config.sops.templates.radicale-secrets.path;
    };
}
