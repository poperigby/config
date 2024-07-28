{ config, lib, pkgs, ... }:

let
    cfg = config.poperigby.services.distrobox;
in
{
    options.poperigby.services.distrobox.enable = lib.mkEnableOption "DistroBox";

    config = lib.mkIf cfg.enable {
        virtualisation.podman.enable = true;

        environment.systemPackages = [ pkgs.distrobox ];
    };
}
