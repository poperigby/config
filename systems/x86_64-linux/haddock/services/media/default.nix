{ ... }:

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
}
