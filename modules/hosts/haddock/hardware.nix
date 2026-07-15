{ ... }:

{
    den.aspects.haddock.nixos =
        { ... }:
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
                kernelParams = [ "microcode.amd_sha_check=off" ];
                blacklistedKernelModules = [
                    # https://cisofy.com/lynis/controls/NETW-3200
                    "dccp"
                    "rds"
                    "sctp"
                    "tipc"
                ];
            };

            hardware.enableRedistributableFirmware = true;

            # Keep microcode updated
            services.ucodenix = {
                enable = true;
                cpuModelId = "00870F10";
            };

        };
}
