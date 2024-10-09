{ ... }:

{
    boot = {
        initrd.availableKernelModules = [
            "xhci_pci"
            "thunderbolt"
            "nvme"
            "usb_storage"
            "sd_mod"
        ];
        kernelModules = [
            "kvm-intel"
        ];
        # https://wiki.archlinux.org/title/Improving_performance#Watchdogs
        kernelParams = [ "nowatchdog" ];
    };

    hardware.enableRedistributableFirmware = true;

    # Keep microcode updated
    services.ucodenix = {
        enable = true;
        cpuSerialNumber = "0008-06C1-0000-0000-0000-0000";
    };
}
