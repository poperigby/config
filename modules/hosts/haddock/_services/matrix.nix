{ config, lib, ... }:

let
    inherit (lib) mkForce;

    matrixDomain = "matrix.haddock.cc";
    livekitDomain = "livekit.haddock.cc";

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
                    new_user_displayname_suffix = "";
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
                    relay_range_start = 50300;
                    relay_range_end = 50400;
                    domain = livekitDomain;
                };
            };
        };
        caddy.virtualHosts = {
            "haddock.cc".extraConfig = # caddy
                ''
                    # Federation well-known
                    header /.well-known/matrix/server Content-Type application/json
                    respond /.well-known/matrix/server `{ "m.server": "${matrixDomain}:443" }` 200

                    # Client well-known — CORS required
                    header /.well-known/matrix/client Content-Type application/json
                    header /.well-known/matrix/client Access-Control-Allow-Origin *
                    respond /.well-known/matrix/client `{ "m.homeserver": { "base_url": "https://${matrixDomain}" }, "org.matrix.msc4143.rtc_foci": [{ "type": "livekit", "livekit_service_url": "https://${livekitDomain}" }] }` 200
                '';
            "${matrixDomain}".extraConfig = ''
                reverse_proxy :6167
            '';
            "${livekitDomain}".extraConfig = ''
                @lk-jwt-service path /sfu/get* /healthz* /get_token*
                route @lk-jwt-service {
                    reverse_proxy :${toString lk-jwt-service.port}
                }

                reverse_proxy :${toString livekit.settings.port}
            '';
        };
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
        livekit.serviceConfig.DynamicUser = mkForce false;
        lk-jwt-service = {
            serviceConfig.DynamicUser = mkForce false;
            environment.LIVEKIT_FULL_ACCESS_HOMESERVERS = "haddock.cc";
        };
    };

    users = {
        users = {
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
