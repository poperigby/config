{ ... }:

{
    imports = [
        ./auditd.nix
        ./auth
        ./caddy
        ./clamav.nix
        ./crowdsec.nix
        ./ddclient.nix
        ./frigate.nix
        ./gatus.nix
        ./geoipupdate.nix
        ./mealie.nix
        ./media
        ./miniflux.nix
        ./postgresql.nix
        ./prusalink.nix
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
