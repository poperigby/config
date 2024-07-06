# Setup based on https://trash-guides.info/Hardlinks/How-to-setup-for/Native/#torrent-clients

# TODO: lo interface has to be up before WebUI is accessible

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
                Application = {
                    FileLogger = {
                        Age = 1;
                        AgeType = 1;
                        Backup = true;
                        DeleteOld = true;
                        Enabled = true;
                        MaxSizeBytes = 66560;
                        Path = "/var/log/qBittorrent";
                    };
                };
                BitTorrent = {
                    Session = {
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
                        Port = 37828;
                        Preallocation = true;
                        QueueingSystemEnabled = false;
                        TempPath = "/tmp/qBittorrent";
                        UseAlternativeGlobalSpeedLimit = true;
                    };
                };
                Core = {
                    AutoDeleteAddedTorrentFile = "IfAdded";
                };
                LegalNotice.Accepted = true;
                Meta = {
                    MigrationVersion = 6;
                };
                Network = {
                    PortForwardingEnabled = false;
                    # Proxy = {
                    #     HostnameLookupEnabled = false;
                    #     Profiles = {
                    #         BitTorrent = true;
                    #         Misc = true;
                    #         RSS = true;
                    #     };
                    # };
                };
                Preferences = {
                    General = {
                        Locale = "en";
                    };
                    Scheduler = {
                        end_time = "@Variant(\0\0\0\xf\x1I\x97\0)";
                        start_time = "@Variant(\0\0\0\xf\x4\xefm\x80)";
                    };
                    WebUI = {
                        # I have Authelia in front of qBittorrent, so WebUI login is unnecessary
                        AuthSubnetWhitelist = "0.0.0.0/0";
                        AuthSubnetWhitelistEnabled = true;
                        HostHeaderValidation = false;
                        LocalHostAuth = false;
                        Password_PBKDF2 = "@ByteArray(sQpetcrwJ1S8WzCggUXJFg==:6vvXog5UQiOPcIrBAsZ4X7Amo9LXHkaYg1YjRyEWVoXxgU5o4LrY5CSit0Bc0+pBkQ6y4D0U930re5if/r2flw==)";
                        UseUPnP = false;
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

    # Setup ProtonVPN WireGuard interface for qBittorrent to connect to
    networking = let
        interface = config.networking.wireguard.interfaces.proton0;
    in {
        wireguard.interfaces.proton0 = {
            ips = [ "10.2.0.2/32" ];
            listenPort = 51820;
            # Add the WireGuard interface to the ProtonVPN network namespace
            interfaceNamespace = namespace;
            privateKeyFile = config.sops.secrets."haddock/protonvpn/private_key".path;
            peers = [
                {
                    allowedIPs = [ "0.0.0.0/0" ];
                    endpoint = "156.146.51.78:51820";
                    publicKey = "mn8WlkJqY66j17ZbwN2DB0Nj74zG/DicuRQZtxtQsTM=";
                }
            ];
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
            # The namespace must exist when qBittorrent starts
            after = [ "wireguard-proton0.service" ];
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
        # Create the ProtonVPN network namespace when the WireGuard interface comes up
        wireguard-proton0.serviceConfig = let
            ip = "${pkgs.iproute}/bin/ip";
        in {
            ExecStartPre = [
                "${ip} netns add ${namespace}"
                # We need the loopback interface to be up to access the WebUI externally
                "${ip} netns exec ${namespace} ip link set lo up"
            ];
            ExecStopPost = [ "${pkgs.iproute}/bin/ip netns del ${namespace}" ];
        };
    };

    sops.secrets = {
        "haddock/protonvpn/private_key".owner = "qbittorrent";
    };
}
