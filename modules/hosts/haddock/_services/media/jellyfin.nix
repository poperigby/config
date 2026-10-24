{ pkgs, ... }:

let
    # scale_vulkan requires a shader compiler at build time.
    jellyfinFfmpeg = pkgs.jellyfin-ffmpeg.overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.glslang ];
        configureFlags = old.configureFlags ++ [ "--enable-filter=scale_vulkan" ];
    });
in
{
    services = {
        jellyfin = {
            enable = true;
            package = pkgs.jellyfin.override { jellyfin-ffmpeg = jellyfinFfmpeg; };
        };
        caddy.virtualHosts."media.haddock.cc".extraConfig = ''
            # Jellyfin uses its own non-standard `MediaBrowser` Authorization
            # scheme. Do not send that header to Authelia: recent Authelia
            # versions reject unknown schemes instead of falling back to the
            # session cookie. `forward_auth` operates on a cloned request, so
            # the original Authorization header is still sent to Jellyfin.
            forward_auth :9091 {
                uri /api/authz/forward-auth
                header_up -Authorization
                copy_headers Remote-User Remote-Groups Remote-Email Remote-Name
            }
            reverse_proxy :8096
        '';
    };

    # Enable hardware acceleration
    hardware.graphics.enable = true;

    environment.systemPackages = [
        # Needed for hardware acceleration
        jellyfinFfmpeg
    ];

    users.users.jellyfin.extraGroups = [
        # Let's Jellyfin's user access rendering devices
        "render"
        "video"
        # Gives access to /mnt/media/data
        "media"
    ];
}
