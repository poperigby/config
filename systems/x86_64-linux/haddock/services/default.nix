{ ... }:

{
  imports = [
    # ./ocis.nix
    ./auditd.nix
    ./auth
    ./caddy.nix
    ./clamav.nix
    ./crowdsec.nix
    ./ddns-updater.nix
    ./findMyDeviceServer.nix
    ./forgejoActions.nix
    ./games
    ./gatus.nix
    ./immich.nix
    ./mealie.nix
    ./media
    ./miniflux.nix
    ./paperless.nix
    ./postgresql.nix
    ./prusalink.nix
    ./radicale.nix
    ./redis.nix
    ./scrutiny.nix
    ./silverbullet.nix
    ./vikunja.nix
  ];

  # Automatically prune all unused pods, containers, images,
  # networks, and volume data on a weekly basis.
  virtualisation.docker.autoPrune = {
    enable = true;
    dates = "weekly";
  };
}
