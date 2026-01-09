{ lib, ... }:

let
    inherit (lib) mkDefault;
in
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
        kernelParams = [
            "nowatchdog"
        ];
        blacklistedKernelModules = [
            # Ryzen hardware watchdog
            "sp5100-tco"
        ];
    };

    hardware = {
        amdgpu.overdrive.enable = true;
        enableRedistributableFirmware = true;
        i2c.enable = true;
        xpadneo.enable = true;
    };

    systemd.tmpfiles.rules = [
        # Reduce Xbox controller rumble intensity by given percentage
        # https://atar-axis.github.io/xpadneo
        "w /sys/module/hid_xpadneo/parameters/rumble_attenuation - - - - 25"
    ];

    # Keep microcode updated
    services.ucodenix = {
        enable = true;
        cpuModelId = "00A60F12";
    };

    nixpkgs.hostPlatform = mkDefault "x86_64-linux";
}
