{ ... }:

{
    imports = [ ./caddy ];

    virtualisation.podman.enable = true;

    # Automatically prune all unused pods, containers, images,
    # networks, and volume data on a weekly basis.
    virtualisation.podman.autoPrune = {
        enable = true;
        dates = "weekly";
    };
}
