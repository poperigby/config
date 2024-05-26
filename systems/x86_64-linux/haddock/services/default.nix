{ ... }:

{
    imports = [
        ./auth
        ./caddy
        ./ddclient.nix
        ./frigate.nix
        ./media
        ./miniflux.nix
        ./postgresql.nix
        ./uptime-kuma.nix
    ];

    # Automatically prune all unused pods, containers, images,
    # networks, and volume data on a weekly basis.
    virtualisation.podman.autoPrune = {
        enable = true;
        dates = "weekly";
    };
}
