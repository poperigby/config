# Setup based on https://trash-guides.info/Hardlinks/How-to-setup-for/Native/#torrent-clients

{ config, inputs, pkgs, ... }:

let
    cfg = config.services.qbittorrent;
    netns = "proton";
in
{
    imports = [
        "${inputs.qbittorrent}/nixos/modules/services/torrent/qbittorrent.nix"
        inputs.vpnconfinement.nixosModules.default
    ];

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
            reverse_proxy 192.168.15.1:${builtins.toString cfg.webuiPort}
        '';
    };

    # Give qBittorrent access to /mnt/media/data/torrents
    users.users.qbittorrent.extraGroups = [ "torrents" ];

    # Define a network namespace with a VPN for qBittorrent
    vpnnamespaces."${netns}" = {
        enable = true;
        wireguardConfigFile = config.sops.templates.wireguard-config-file.path;
        accessibleFrom = [
            "192.168.1.0/24"
        ];
        portMappings = [
            {
                # Make the WebUI accessible on the bridge interface
                from = cfg.webuiPort;
                to = cfg.webuiPort;
            }
        ];
    };

    systemd.services = {
        qbittorrent = {
            # Make qBittorrent run in the ProtonVPN network namespace
            vpnconfinement = {
                enable = true;
                vpnnamespace = netns;
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
                # The VPN connection interface
                VPN_INTERFACE = "${netns}0";
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
            };
            # Make the port updater run in the ProtonVPN network namespace
            vpnconfinement = {
                enable = true;
                vpnnamespace = netns;
            };
        };
        # Update my MyAnonaMouse session IP
        "${netns}".serviceConfig.ExecStartPost = let
            update-mam-ip = pkgs.writeShellScriptBin "update-mam-ip" ''
                ${pkgs.curl}/bin/curl -b "mam_id=$(cat /run/secrets/haddock/myanonamouse/id)" https://t.myanonamouse.net/json/dynamicSeedbox.php
            '';
        in [ "${update-mam-ip}/bin/update-mam-ip" ];
    };

    sops = {
        templates.wireguard-config-file = {
            content = ''
                [Interface]
                # Key for Haddock
                # Bouncing = 20
                # NetShield = 1
                # Moderate NAT = off
                # NAT-PMP (Port Forwarding) = on
                # VPN Accelerator = on
                PrivateKey = ${config.sops.placeholder."haddock/protonvpn/private_key"}
                Address = 10.2.0.2/32
                DNS = 10.2.0.1

                [Peer]
                # US-WA#103
                PublicKey = mdgZ6wT7AXGznoYqxERZexx9aPEd/FhQ+P6fdXCBuVQ=
                AllowedIPs = 0.0.0.0/0
                Endpoint = 149.102.254.78:51820
            '';
            owner = "qbittorrent";
        };
        secrets = {
            "haddock/protonvpn/private_key".owner = "qbittorrent";
            "haddock/myanonamouse/id" = {};
        };
    };
}
