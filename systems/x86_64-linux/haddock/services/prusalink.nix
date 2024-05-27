{ ... }:

{
    services.caddy.virtualHosts."print.haddock.cc".extraConfig = ''
        import auth
        reverse_proxy http://192.168.1.27:80
    '';
}
