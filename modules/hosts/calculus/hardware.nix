{ lib, ... }:

{
    den.aspects.calculus.nixos = {
        boot = {
            initrd.availableKernelModules = [
                "ahci"
                "nvme"
                "sd_mod"
                "sr_mod"
                "sr_mod"
                "usb_storage"
                "usbhid"
                "xhci_pci"
            ];
            kernelModules = [
                "k10temp"
                "kvm-amd"
                "nct6775"
            ];
            # https://wiki.archlinux.org/title/Improving_performance#Watchdogs
            kernelParams = [
                "nowatchdog"
            ];
            blacklistedKernelModules = [
                # Ryzen hardware watchdog
                "sp5100-tco"
            ];
        };

        hardware.enableRedistributableFirmware = true;

        # Keep microcode updated
        services.ucodenix = {
            enable = true;
            cpuModelId = "00A20F12";
        };

    };
}
