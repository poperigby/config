# TODO: qBittorrent only needs access to data/torrents

{ ... }:

{
    poperigby.services.qbittorrent = {
        enable = true;
        webuiPort = 8082;
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
                    # Setup based on https://trash-guides.info/Hardlinks/How-to-setup-for/Native/#torrent-clients
                    DefaultSavePath = "/mnt/hdd0/data/torrents";
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
                MailNotification = {
                    req_auth = true;
                };
                Scheduler = {
                    end_time = "@Variant(\0\0\0\xf\x1I\x97\0)";
                    start_time = "@Variant(\0\0\0\xf\x4\xefm\x80)";
                };
                WebUI = {
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

    # Give Jellyfin access to /mnt/media/data/torrents
    users.users.qbittorrent.extraGroups = [ "torrents" ];
}
