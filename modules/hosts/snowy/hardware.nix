{ ... }:

{
    den.aspects.snowy.nixos =
        { config, ... }:

        {
            boot = {
                # https://wiki.archlinux.org/title/Improving_performance#Watchdogs
                kernelParams = [
                    "nowatchdog"
                ];
                extraModulePackages = with config.boot.kernelPackages; [
                    # Control motherboard connected fans
                    nct6687d
                ];
                kernelModules = [
                    "nct6687"
                    # NT synchronization primitives for Wine/Proton
                    "ntsync"
                ];
                blacklistedKernelModules = [
                    # Ryzen hardware watchdog
                    "sp5100-tco"
                ];
            };

            hardware = {
                facter.reportPath = ./facter.json;
                amdgpu.overdrive.enable = true;
                enableRedistributableFirmware = true;
                i2c.enable = true;
            };

            # GPU power limit, undervolt, and clocks
            services.lact.enable = true;

            # Keep microcode updated
            services.ucodenix = {
                enable = true;
                cpuModelId = "00A60F12";
            };

        };
}
