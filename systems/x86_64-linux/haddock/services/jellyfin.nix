{ pkgs, ... }:

{
    services.jellyfin.enable = true;

    environment.systemPackages = with pkgs; [
        # The web interface
        jellyfin-web
        # Needed for hardware acceleration
        jellyfin-ffmpeg
    ];

    # Let's Jellyfin user access rendering devices
    users.users.jellyfin.extraGroups = [
        "render"
        "video"
    ];
}
