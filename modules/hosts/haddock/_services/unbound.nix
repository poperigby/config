{ ... }:

{
    services.unbound = {
        enable = true;
        settings = {
            server = {
                interface = [ "127.0.0.1" ];
                # https://continuwuity.org/advanced/dns#unbound
                rrset-cache-size = "64M";
                msg-cache-size = "64M";
                discard-timeout = "4800";
            };
            forward-zone = [
                {
                    name = ".";
                    forward-addr = [
                        "192.168.1.1"
                    ];
                }
            ];
            remote-control.control-enable = true;
        };
    };

    networking.nameservers = [ "127.0.0.1" ];
}
