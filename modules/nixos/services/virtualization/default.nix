{ config, lib, ... }:

let
    cfg = config.poperigby.services.virtualization;
    gui = config.poperigby.suites.gui;
in
{
    options.poperigby.services.virtualization.enable = lib.mkEnableOption "Enable virtualization with libvirt";

    config = lib.mkIf cfg.enable {
        virtualisation.libvirtd.enable = true;

        programs.virt-manager.enable = gui.enable;
    };
}
