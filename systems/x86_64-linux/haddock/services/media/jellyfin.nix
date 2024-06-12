# TODO: Jellyfin only needs access to data/media

{ pkgs, ... }:

{
    services = {
        jellyfin = {
            enable = true;
        };
        caddy.virtualHosts."media.haddock.cc".extraConfig = ''
            #import auth
            reverse_proxy :8096
        '';
    };

    # This is needed to enabled Vulkan 🤔
    hardware.opengl.enable = true;

    environment.systemPackages = with pkgs; [
        # Needed for hardware acceleration
        jellyfin-ffmpeg
    ];

    # Let's Jellyfin's user access rendering devices
    users.users.jellyfin.extraGroups = [
        "render"
        "video"
        # Gives access to /mnt/media/data/media
        "media"
    ];
}
