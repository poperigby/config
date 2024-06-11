{ ... }:

{
    imports = [
        ./arr.nix
        ./jellyfin.nix
        ./qbittorrent.nix
    ];

    users = {
        users = {
            # This user owns /mnt/media/data/media
            media = {
                group = "media";
                isSystemUser = true;
            };
            # This user owns /mnt/media/data/torrents
            torrents = {
                group = "torrents";
                isSystemUser = true;
            };
        };
        # Members of this group are able to access /mnt/media/data/media
        groups.media = {};
        # Members of this group are able to access /mnt/media/data/torrents
        groups.torrents = {};
    };
}
