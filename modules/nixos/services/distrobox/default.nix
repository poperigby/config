{ config, lib, pkgs, ... }:

let
    cfg = config.custom.services.distrobox;
in
{
    options.custom.services.distrobox.enable = lib.mkEnableOption "DistroBox";

    config = lib.mkIf cfg.enable {
        virtualisation.podman.enable = true;

        environment.systemPackages = [ pkgs.distrobox ];
    };
}
