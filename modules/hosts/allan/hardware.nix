{ ... }:

{
    den.aspects.allan.nixos = {
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
            blacklistedKernelModules = [
                # Intel watchdog
                "iTCO_wdt"
            ];
            # https://wiki.archlinux.org/title/Improving_performance#Watchdogs
            kernelParams = [ "nowatchdog" ];
        };

        # Allow firmware updates
        hardware.enableRedistributableFirmware = true;
    };
}
