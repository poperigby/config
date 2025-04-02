{ lib, ... }:

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
      # Don't perform microcode checksum, as it prevents the microcode from loading
      "microcode.amd_sha_check=off"
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

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
