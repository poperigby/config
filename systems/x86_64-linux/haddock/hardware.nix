{ config, ... }:

{
    boot = {
        initrd.availableKernelModules = [
            "xhci_pci"
            "ahci"
            "usbhid"
            "usb_storage"
            "sd_mod"
        ];
        kernelModules = [
            "k10temp"
            "nct6775"
        ];
        blacklistedKernelModules = [
            # https://cisofy.com/lynis/controls/NETW-3200
            "dccp"
            "rds"
            "sctp"
            "tipc"
        ];
        extraModulePackages = with config.boot.kernelPackages; [
            # Google Coral TPU driver
            gasket
        ];
    };

    # This is defined here instead of in drives.nix because I don't want Disko formatting these
    # This is actually multiple drives combined into one filesystem
    fileSystems."/mnt/media" = {
        device = "/dev/disk/by-uuid/45208395-9c37-4bc4-ae87-c4ab5f39794b";
        fsType = "btrfs";
    };

    hardware.enableRedistributableFirmware = true;

    # Keeps microcode updated
    services.ucodenix = {
        enable = true;
        cpuSerialNumber = "00A2-0F12-0000-0000-0000-0000";
    };
}
