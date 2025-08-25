{ ... }:

{
  imports = [
    # ./moonfire.nix
    ./auditd.nix
    ./auth
    ./binaryCache.nix
    ./caddy.nix
    ./clamav.nix
    ./crowdsec.nix
    ./ddns.nix
    ./findMyDeviceServer.nix
    ./forgejoActions.nix
    ./games
    ./immich.nix
    ./karakeep.nix
    ./mealie.nix
    ./media
    ./miniflux.nix
    ./postgresql.nix
    ./prusalink.nix
    ./redis.nix
    ./rustical.nix
    ./scrutiny.nix
    ./trilium.nix
    ./vikunja.nix
  ];

  # Automatically prune all unused pods, containers, images,
  # networks, and volume data on a weekly basis.
  virtualisation.docker.autoPrune = {
    enable = true;
    dates = "weekly";
  };
}
