{ pkgs, ... }:

{
    services = {
        radicale = {
            enable = true;
            settings = {
                # auth = {
                #     type = "radicale_auth_ldap";
                #     ldap_url = "ldap://localhost:3890";
                #     ldap_base = "dc=haddock,dc=cc";
                #     ldap_attribute = "uid";
                #     ldap_filter = "(objectClass=person)";
                #     ldap_binddn = "uid=radicale,ou=people,dc=haddock,dc=cc";
                #     ldap_password = "CHANGEME";
                #     ldap_scope = "LEVEL";
                #     ldap_support_extended = "no";
                # };
            };
        };
        caddy.virtualHosts."dav.haddock.cc".extraConfig = ''
            redir / /radicale/
            handle_path /radicale/* {
                reverse_proxy localhost:5232 {
                    header_up X-Script-Name /radicale
                }
            }
        '';
    };

    environment.systemPackages = [ pkgs.poperigby.radicale3-ldap-auth ];

    systemd.services.radicale = let
       dependencies = [ "lldap.nix" ];
    in {
        after = dependencies;
        requires = dependencies;
    };
}
