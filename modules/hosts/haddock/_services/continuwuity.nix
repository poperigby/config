{ config, lib, ... }:

let
    inherit (lib) mkForce;

    socketPath = "/var/run/continuwuity/continuwuity.sock";

    matrixDomain = "matrix.haddock.cc";
    livekitDomain = "livekit.haddock.cc";
    turnDomain = "turn.haddock.cc";

    lk-jwt-service = config.services.lk-jwt-service;
    livekit = config.services.livekit;
in
{
    services = {
        matrix-continuwuity = {
            enable = true;
            settings = {
                global = {
                    server_name = "haddock.cc";
                    unix_socket_path = socketPath;

                    new_user_displayname_suffix = "";

                    # Unbound provides the cache for federation lookups.
                    dns_cache_entries = 0;
                    # TCP isolates local DNS queries from delayed upstream UDP replies.
                    query_over_tcp_only = true;
                    # https://continuwuity.org/guides/performance.html#cache-capacities
                    cache_capacity_modifier = 2.0;
                    # Don't wast time looking up IPv6 addresses.
                    ip_lookup_strategy = 1;
                    # https://continuwuity.org/guides/performance.html#tuning-your-trusted-servers
                    trusted_servers = [
                        "codestorm.net"
                        "starstruck.systems"
                        "unredacted.org"
                        "matrix.org"
                    ];
                    trusted_server_batch_size = 2048;

                    oauth.oidc = {
                        discovery_url = "https://auth.haddock.cc";
                        client_id = "continuwuity";
                        client_secret_file =
                            config.sops.secrets."haddock/continuwuity/oidc_client_secret/continuwuity".path;
                        additional_scopes = [
                            "email"
                            "profile"
                        ];
                    };

                    well_known = {
                        client = "https://${matrixDomain}";
                        server = "${matrixDomain}:443";
                    };

                    matrix_rtc.foci = [
                        {
                            type = "livekit";
                            livekit_service_url = "https://${livekitDomain}";
                        }
                    ];
                };
            };

        };
        # https://continuwuity.org/calls/livekit
        lk-jwt-service = {
            enable = true;
            port = 1025;
            livekitUrl = "wss://${livekitDomain}";
            keyFile = config.sops.templates.livekit_keyfile.path;
        };
        livekit = {
            enable = true;
            keyFile = config.sops.templates.livekit_keyfile.path;
            settings = {
                bind_addresses = [ "" ];
                rtc = {
                    tcp_port = 7881;
                    port_range_start = 50100;
                    port_range_end = 50200;
                    use_external_ip = true;
                    enable_loopback_candidate = false;
                };
                turn = {
                    enabled = true;
                    udp_port = 3478;
                    tls_port = 5349;
                    external_tls = true;
                    relay_range_start = 50300;
                    relay_range_end = 50400;
                    domain = turnDomain;
                };
            };
        };
        caddy = {
            globalConfig = # Caddy
                ''
                    # Share TCP/443 between HTTPS and LiveKit's embedded TURN server.
                    # Connections for turn.haddock.cc are intercepted by their TLS SNI,
                    # all other connections continue to Caddy's normal HTTP TLS handler.
                    # Caddy terminates TLS and proxies TURN over loopback to port 5349,
                    # which is intentionally not opened in the NixOS firewall.
                    servers {
                        listener_wrappers {
                            layer4 {
                                @turn tls sni turn.haddock.cc
                                route @turn {
                                    tls
                                    proxy 127.0.0.1:5349
                                }
                            }
                            tls
                        }
                    }
                '';
            virtualHosts = {
                "haddock.cc".extraConfig = ''
                    reverse_proxy /.well-known/matrix/* unix/${socketPath}
                '';
                "${matrixDomain}".extraConfig = ''
                    reverse_proxy unix/${socketPath}
                '';
                "${livekitDomain}".extraConfig = ''
                    @lk-jwt-service path /sfu/get* /healthz* /get_token*
                    route @lk-jwt-service {
                        reverse_proxy :${toString lk-jwt-service.port}
                    }

                    reverse_proxy :${toString livekit.settings.port}
                '';
                # Provisions the certificate used by the Layer 4 TURN/TLS route.
                "${turnDomain}".extraConfig = ''
                    respond 404
                '';
            };
        };
        # https://continuwuity.org/guides/oidc
        authelia.oidcClients.haddock = [
            {
                client_name = "Continuwuity";
                client_id = "continuwuity";
                client_secret = config.sops.placeholder."haddock/continuwuity/oidc_client_secret/authelia";
                authorization_policy = "two_factor";
                redirect_uris = [ "https://${matrixDomain}/_continuwuity/oidc/complete" ];
                scopes = [
                    "openid"
                    "email"
                    "profile"
                ];
            }
        ];
    };

    networking.firewall =
        let
            rtc = livekit.settings.rtc;
            turn = livekit.settings.turn;
        in
        {
            allowedTCPPorts = [ rtc.tcp_port ];
            allowedUDPPorts = [ turn.udp_port ];
            allowedUDPPortRanges = [
                {
                    from = rtc.port_range_start;
                    to = rtc.port_range_end;
                }
                {
                    from = turn.relay_range_start;
                    to = turn.relay_range_end;
                }
            ];
        };

    systemd.services = {
        continuwuity = {
            after = [ "unbound.service" ];
        };
        livekit.serviceConfig.DynamicUser = mkForce false;
        lk-jwt-service = {
            serviceConfig.DynamicUser = mkForce false;
            environment.LIVEKIT_FULL_ACCESS_HOMESERVERS = "haddock.cc";
        };
    };

    users = {
        users = {
            # Give Caddy permission to access the socket
            caddy.extraGroups = [ "continuwuity" ];
            livekit = {
                group = "livekit";
                isSystemUser = true;
            };
            lk-jwt-service = {
                group = "lk-jwt-service";
                isSystemUser = true;
            };
        };
        groups = {
            livekit = { };
            lk-jwt-service = { };
        };
    };

    sops = {
        secrets = {
            "haddock/continuwuity/oidc_client_secret/continuwuity".owner = "continuwuity";
            "haddock/continuwuity/oidc_client_secret/authelia".owner = "authelia-haddock";
            "haddock/livekit/api_key" = { };
            "haddock/livekit/api_secret" = { };
        };
        templates =
            let
                key = config.sops.placeholder."haddock/livekit/api_key";
                secret = config.sops.placeholder."haddock/livekit/api_secret";
                keyFile = ''
                    ${key}: ${secret}
                '';
            in
            {
                livekit_keyfile = {
                    content = keyFile;
                    owner = "livekit";
                    restartUnits = [
                        "livekit.service"
                        "lk-jwt-service.service"
                    ];
                };
            };
    };
}
