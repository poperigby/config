{ ... }:

{
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
        kernelParams = [ "nowatchdog" ];
        blacklistedKernelModules = [
            # Ryzen hardware watchdog
            "sp5100-tco"
        ];
    };

    # I define this is here instead of in drives.nix because I don't want Disko formatting these
    fileSystems = {
        "/mnt/ssd0" = {
            device = "/dev/disk/by-uuid/be9f123f-1da8-4821-bf2a-a1ac1f00d4ab";
            fsType = "ext4";
            options = [ "noatime" ];
        };
        "/mnt/hdd0" = {
            device = "/dev/disk/by-uuid/5d997a5b-4ddd-4962-bc36-13faf673d881";
            fsType = "ext4";
            options = [ "noatime" ];
        };
    };

    hardware.enableRedistributableFirmware = true;

    # Keep microcode updated
    services.ucodenix = {
        enable = true;
        cpuSerialNumber = "0087-0F10-0000-0000-0000-0000";
    };
}
