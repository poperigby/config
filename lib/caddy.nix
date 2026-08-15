{ ... }:

{
    # Import Authelia ForwardAuth directive and reverse proxy the service using the given port.
    authReverseProxy = port: ''
        import auth
        reverse_proxy :${toString port}
    '';

    # Import Authelia ForwardAuth directive and reverse proxy the service using the given address and port.
    authReverseProxy' = address: port: ''
        import auth
        reverse_proxy ${address}:${toString port}
    '';
}
