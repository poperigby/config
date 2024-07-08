# Setup based on https://trash-guides.info/Hardlinks/How-to-setup-for/Native/#torrent-clients

{ config, inputs, pkgs, ... }:

let
    cfg = config.services.qbittorrent;
    namespace = "wg-proton0";
in
{
    imports = [ "${inputs.qbittorrent}/nixos/modules/services/torrent/qbittorrent.nix" ];

    services = {
        qbittorrent = {
            enable = true;
            webuiPort = 8083;
            torrentingPort = 4096;
            serverConfig = {
                Application.FileLogger = {
                    Age = 1;
                    AgeType = 1;
                    Backup = true;
                    DeleteOld = true;
                    Enabled = true;
                    MaxSizeBytes = 66560;
                    Path = "/var/log/qBittorrent";
                };
                BitTorrent.Session = {
                    AlternativeGlobalDLSpeedLimit = 0;
                    AlternativeGlobalUPSpeedLimit = 0;
                    BTProtocol = "TCP";
                    BandwidthSchedulerEnabled = true;
                    DefaultSavePath = "/mnt/media/data/torrents";
                    DisableAutoTMMByDefault = false;
                    # DisableAutoTMMTriggers = {
                    #     CategorySavePathChanged = false;
                    #     DefaultSavePathChanged = false;
                    # };
                    ExcludedFileNames = "";
                    GlobalDLSpeedLimit = 1736704;
                    GlobalUPSpeedLimit = 1736704;
                    Preallocation = true;
                    QueueingSystemEnabled = false;
                    TempPath = "/tmp/qBittorrent";
                    UseAlternativeGlobalSpeedLimit = true;
                    # Bind to the ProtonVPN WireGuard interface to avoid leaks
                    Interface = "proton0";
                    InterfaceName = "proton0";
                };
                Core.AutoDeleteAddedTorrentFile = "IfAdded";
                LegalNotice.Accepted = true;
                Meta.MigrationVersion = 6;
                Network.PortForwardingEnabled = false;
                Preferences = {
                    General.Locale = "en";
                    Scheduler = {
                        end_time = "@Variant(\0\0\0\xf\x1I\x97\0)";
                        start_time = "@Variant(\0\0\0\xf\x4\xefm\x80)";
                    };
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
        caddy.virtualHosts."torrent.haddock.cc".extraConfig = ''
            import auth
            reverse_proxy :${builtins.toString cfg.webuiPort}
        '';
    };

    # Give qBittorrent access to /mnt/media/data/torrents
    users.users.qbittorrent.extraGroups = [ "torrents" ];

    networking = let
        interface = config.networking.wireguard.interfaces.proton0;
    in {
        # ProtonVPN WireGuard interface for qBittorrent to connect to
        wireguard.interfaces.proton0 = {
            ips = [ "10.2.0.2/32" ];
            listenPort = 51820;
            # Add the WireGuard interface to the ProtonVPN network namespace
            interfaceNamespace = namespace;
            privateKeyFile = config.sops.secrets."haddock/protonvpn/private_key".path;
            peers = [
                {
                    # US-WA#103
                    allowedIPs = [ "0.0.0.0/0" ];
                    endpoint = "149.102.254.78:51820";
                    publicKey = "mdgZ6wT7AXGznoYqxERZexx9aPEd/FhQ+P6fdXCBuVQ=";
                }
            ];
            preSetup = [
                # Create the ProtonVPN network namespace before the WireGuard interface comes up
                "ip netns add ${namespace}"
                # We need the loopback interface to be up to access the WebUI externally
                "ip netns exec ${namespace} ip link set lo up"
            ];
            # Get rid of the network namespace after the interface shuts down
            postShutdown = [ "ip netns del ${namespace}" ];
        };
        firewall = {
            allowedUDPPorts = [ interface.listenPort ];
            # Required to reach the port that's forwarded from inside the ProtonVPN network namespace
            allowedTCPPorts = [ cfg.webuiPort ];
        };
    };
    systemd.services = {
        qbittorrent = {
            # Make qBittorrent run in the ProtonVPN network namespace
            serviceConfig.NetworkNamespacePath = "/run/netns/${namespace}";
            # We don't want qBittorrent running without the namespace and ProtonVPN connection
            after = [ "wireguard-proton0.service" ];
            bindsTo = [ "wireguard-proton0.service" ];
        };
        # Forward the qBittorrent Web UI ports from inside the ProtonVPN network namespace
        qbittorrent-webui-port-forwarder = {
            enable = true;
            description = "Forward the qBittorrent Web UI ports from inside the ProtonVPN network namespace";
            wants = [ "qbittorrent.service" ];
            wantedBy = [ "multi-user.target" ];
            after = [ "qbittorrent.service" ];
            serviceConfig = let
                netnsPublish = "${pkgs.poperigby.netns-publish}/bin/netns-publish";
                webuiPort = builtins.toString cfg.webuiPort ;
            in {
                Type = "simple";
                ExecStart = "${netnsPublish} ${webuiPort} ${namespace} 127.0.0.1:${webuiPort}";
            };
        };
        # Automatically update the qBittorrent torrenting port with the one forwarded in ProtonVPN
        qbittorrent-protonvpn-port-update = {
            enable = true;
            description = "Automatically update the qBittorrent torrenting port with the one forwarded in ProtonVPN";
            wants = [ "qbittorrent.service" ];
            wantedBy = [ "multi-user.target" ];
            after = [ "qbittorrent.service" ];
            environment = {
                QBITTORRENT_WEBUI_HOST = "127.0.0.1";
                QBITTORRENT_WEBUI_PORT = builtins.toString cfg.webuiPort;
                QBITTORRENT_WEBUI_USERNAME = "admin";
                QBITTORRENT_WEBUI_PASSWORD = "adminadmin";
                INITIAL_DELAY_SEC = "10";
                CHECK_INTERVAL_SEC = "60";
                ERROR_INTERVAL_SEC = "5";
                ERROR_INTERVAL_COUNT = "5";
            };
            serviceConfig = {
                Type = "simple";
                ExecStart = "${pkgs.poperigby.qbittorrent-protonvpn-port-update}/bin/qbittorrent-protonvpn-port-update";
                # Make the port updater run in the ProtonVPN network namespace
                NetworkNamespacePath = "/run/netns/${namespace}";
            };
        };
    };

    sops.secrets = {
        "haddock/protonvpn/private_key".owner = "qbittorrent";
    };
}
