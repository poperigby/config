{ config, lib, ... }:

let
    cfg = config.custom.services.virtualization;
    gui = config.custom.suites.gui;
in
{
    options.custom.services.virtualization.enable = lib.mkEnableOption "Enable virtualization with libvirt";

    config = lib.mkIf cfg.enable {
        virtualisation.libvirtd.enable = true;

        programs.virt-manager.enable = gui.enable;
    };
}
