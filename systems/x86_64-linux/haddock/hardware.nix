{ lib, ... }:

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
      "gasket"
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
    # extraModulePackages = with config.boot.kernelPackages; [
    #   # Google Coral TPU driver
    #   gasket
    # ];
  };

  hardware.enableRedistributableFirmware = true;

  # Keep microcode updated
  services.ucodenix = {
    enable = true;
    cpuModelId = "00870F10";
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
