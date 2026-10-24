# Setup based on https://trash-guides.info/Hardlinks/How-to-setup-for/Native/#torrent-clients

{
    config,
    lib,
    pkgs,
    ...
}:

let
    inherit (lib) getExe;
    inherit (lib.local.caddy) authReverseProxy';

    cfg = config.services.qbittorrent;
    netns = "proton";
in
{
    services = {
        qbittorrent = {
            enable = true;
            # To give qBittorrent access to /mnt/media/data, and make hardlinks work
            group = "media";
            webuiPort = 8083;
            torrentingPort = 4096;
            serverConfig = {
                BitTorrent.Session = {
                    ## Limits
                    # 80% of max speed in the VPN
                    GlobalDLSpeedLimit = 432000;
                    GlobalUPSpeedLimit = 184000;
                    # http://infinite-source.de/az/az-calc.html
                    MaxConnections = 1200;
                    MaxConnectionsPerTorrent = 111;
                    MaxUploads = 14;
                    MaxUploadsPerTorrent = 14;
                    ## Automatic torrent management
                    DisableAutoTMMByDefault = false;
                    DisableAutoTMMTriggers = {
                        CategorySavePathChanged = false;
                        DefaultSavePathChanged = false;
                    };
                    ## Paths
                    DefaultSavePath = "/mnt/media/data/torrents";
                    ## Misc.
                    BTProtocol = "TCP";
                    Preallocation = true;
                    QueueingSystemEnabled = false;
                };
                Core.AutoDeleteAddedTorrentFile = "IfAdded";
                LegalNotice.Accepted = true;
                Meta.MigrationVersion = 6;
                Network.PortForwardingEnabled = false;
                Preferences = {
                    General.Locale = "en";
                    WebUI = {
                        # I have Authelia in front of qBittorrent, so WebUI login is unnecessary
                        AuthSubnetWhitelist = "0.0.0.0/0";
                        AuthSubnetWhitelistEnabled = true;
                        HostHeaderValidation = false;
                        CSRFProtection = false;
                    };
                };
            };
        };
        caddy.virtualHosts."torrent.haddock.cc".extraConfig =
            let
                namespaceAddress = config.vpnNamespaces.${netns}.namespaceAddress;
            in
            authReverseProxy' namespaceAddress cfg.webuiPort;
    };

    systemd.services = {
        qbittorrent = {
            vpnConfinement = {
                enable = true;
                vpnNamespace = netns;
            };
        };
        # Automatically update the qBittorrent torrenting port with the one forwarded in ProtonVPN
        qbittorrent-vpn-port-update = {
            enable = true;
            description = "Automatically update the qBittorrent torrenting port with the one forwarded in ProtonVPN";
            after = [ "qbittorrent.service" ];
            requires = [ "qbittorrent.service" ];
            wantedBy = [ "multi-user.target" ];
            environment = {
                # The VPN connection interface
                VPN_INTERFACE = "${netns}0";
                QBITTORRENT_WEBUI_HOST = "127.0.0.1";
                QBITTORRENT_WEBUI_PORT = toString cfg.webuiPort;
                QBITTORRENT_WEBUI_USERNAME = "admin";
                QBITTORRENT_WEBUI_PASSWORD = "adminadmin";
                INITIAL_DELAY_SEC = "10";
                CHECK_INTERVAL_SEC = "60";
                ERROR_INTERVAL_SEC = "5";
                ERROR_INTERVAL_COUNT = "5";
            };
            serviceConfig = {
                Type = "simple";
                ExecStart = getExe pkgs.local.qbittorrent-vpn-port-update;
            };
            vpnConfinement = {
                enable = true;
                vpnNamespace = netns;
            };
        };
        # Update my MyAnonaMouse session IP
        update-mam-ip = {
            description = "Update my MyAnonaMouse session IP";
            script = ''
                set -euo pipefail

                status=0
                response=$(${getExe pkgs.curl} \
                    --fail-with-body \
                    --ipv4 \
                    --show-error \
                    --silent \
                    --cookie "mam_id=$(<${config.sops.secrets."haddock/myanonamouse/id".path})" \
                    https://t.myanonamouse.net/json/dynamicSeedbox.php) || status=$?

                # MAM explains rejections in the response body
                printf '%s\n' "$response"
                if ((status != 0)); then
                    exit "$status"
                fi
                ${getExe pkgs.jq} --exit-status '.Success == true' <<< "$response" >/dev/null
            '';
            vpnConfinement = {
                enable = true;
                vpnNamespace = netns;
            };
        };
    };

    systemd.timers.update-mam-ip = {
        description = "Periodically update my MyAnonaMouse session IP";
        wantedBy = [ "timers.target" ];
        timerConfig = {
            OnBootSec = "5m";
            OnUnitActiveSec = "1h";
            Persistent = true;
        };
    };

    sops.secrets."haddock/myanonamouse/id" = { };
}
