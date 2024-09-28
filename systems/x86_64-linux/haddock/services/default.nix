{ ... }:

{
    imports = [
        ./auditd.nix
        ./auth
        ./caddy.nix
        ./clamav.nix
        ./crowdsec.nix
        ./ddclient.nix
        ./frigate.nix
        ./gatus.nix
        ./immich.nix
        ./mealie.nix
        ./media
        ./miniflux.nix
        ./ocis.nix
        ./paperless.nix
        ./postgresql.nix
        ./prusalink.nix
        ./radicale.nix
        ./redis.nix
        ./scrutiny.nix
        ./vikunja.nix
    ];

    # Automatically prune all unused pods, containers, images,
    # networks, and volume data on a weekly basis.
    virtualisation.podman.autoPrune = {
        enable = true;
        dates = "weekly";
    };
}
