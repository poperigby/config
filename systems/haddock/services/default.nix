{ ... }:

{
    imports = [
        ./auth
        ./caddy
        ./ddclient.nix
        ./jellyfin.nix
        ./miniflux.nix
        ./postgresql.nix
        ./qbittorrent.nix
    ];

    # Automatically prune all unused pods, containers, images,
    # networks, and volume data on a weekly basis.
    virtualisation.podman.autoPrune = {
        enable = true;
        dates = "weekly";
    };
}
