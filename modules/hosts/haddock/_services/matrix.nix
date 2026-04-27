{ ... }:

{
    services = {
        matrix-continuwuity = {
            enable = true;
            settings = {
                global = {
                    server_name = "haddock.cc";
                };
            };

        };
        caddy.virtualHosts."haddock.cc, haddock.cc:8448".extraConfig = ''
            reverse_proxy :6167
        '';
    };

    networking.firewall.allowedTCPPorts = [ 8448 ];
}
