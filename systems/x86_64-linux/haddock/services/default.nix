{ ... }:

{
    imports = [
        ./auth
        ./caddy
        ./ddclient.nix
        ./frigate.nix
        ./gatus.nix
        ./mealie
        ./media
        ./miniflux.nix
        ./nextcloud.nix
        ./postgresql.nix
        ./prusalink.nix
    ];

    # Automatically prune all unused pods, containers, images,
    # networks, and volume data on a weekly basis.
    virtualisation.podman.autoPrune = {
        enable = true;
        dates = "weekly";
    };
}
