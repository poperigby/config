{ ... }:

{
    imports = [
        ./arr.nix
        ./jellyfin.nix
        ./qbittorrent.nix
    ];

    # Members of this group are able to access /mnt/hdd0/data/media
    users.groups.media = {};
}
