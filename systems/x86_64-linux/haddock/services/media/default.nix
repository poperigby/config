{ config, ... }:

{
  imports = [
    ./arr.nix
    ./jellyfin.nix
    ./qbittorrent.nix
  ];

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
  vpnNamespaces."proton" = {
    enable = true;
    wireguardConfigFile = config.sops.templates.wireguard-config-file.path;
    accessibleFrom = [
      "192.168.1.0/24"
    ];
    portMappings =
      let
        qbittorrent = config.services.qbittorrent;
      in
      [
        # Make web UIs accessible on the bridge interface
        {
          # qBittorrent
          from = qbittorrent.webuiPort;
          to = qbittorrent.webuiPort;
        }
        {
          # Prowlarr
          from = 9696;
          to = 9696;
        }
        {
          # Radarr
          from = 7878;
          to = 7878;
        }
        {
          # Readarr
          from = 8787;
          to = 8787;
        }
        {
          # Sonarr
          from = 8989;
          to = 8989;
        }
      ];
  };

  sops = {
    templates.wireguard-config-file = {
      content = # ini
        ''
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
    secrets."haddock/protonvpn/private_key".owner = "qbittorrent";
  };
}
