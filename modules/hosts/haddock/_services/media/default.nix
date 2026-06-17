{ config, ... }:

let
    qbittorrent = config.services.qbittorrent;
in
{
    users = {
        # This user owns /mnt/media/data
        users.media = {
            group = "media";
            isSystemUser = true;
        };
        # Members of this group are able to access /mnt/media/data
        groups.media = { };
    };

    # Define a network namespace with a VPN for qBittorrent and Prowlarr
    vpnNamespaces.proton = {
        enable = true;
        wireguardConfigFile = config.sops.templates.wireguard-config-file.path;
        accessibleFrom = [
            "192.168.1.0/24"
        ];
        # Make qBittorrent web UI accessible on the bridge interface
        portMappings = [
            {
                from = qbittorrent.webuiPort;
                to = qbittorrent.webuiPort;
            }
        ];
    };

    sops = {
        templates.wireguard-config-file = {
            content = # ini
                ''
                    [Interface]
                    # Key for Haddock
                    # Bouncing = 8
                    # NetShield = 1
                    # Moderate NAT = off
                    # NAT-PMP (Port Forwarding) = on
                    # VPN Accelerator = off
                    PrivateKey = ${config.sops.placeholder."haddock/protonvpn/private_key"}
                    Address = 10.2.0.2/32, 2a07:b944::2:2/128
                    DNS = 10.2.0.1, 2a07:b944::2:1

                    [Peer]
                    # US-WA#252
                    PublicKey = 1kVqXoxxuSR3WrvykYTRxQD73oQvMtmJfQq7X+HlAQo=
                    AllowedIPs = 0.0.0.0/0, ::/0
                    Endpoint = 149.40.51.227:51820

                    # Uncomment the following line (delete the # symbol) to connect to Proton VPN using IPv6.
                    # Endpoint = [2a02:6ea0:d802:6228::10]:51820
                    PersistentKeepalive = 25
                '';
            owner = "qbittorrent";
        };
        secrets."haddock/protonvpn/private_key".owner = "qbittorrent";
    };
}
