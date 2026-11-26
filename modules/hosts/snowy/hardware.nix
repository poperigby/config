{ ... }:

{
    den.aspects.snowy.nixos =
        { config, pkgs, ... }:

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
                graphics = {
                    package = pkgs.versions.mesa."26.2.6";
                    package32 = pkgs.versions.mesa_i686."26.2.6";
                };
                facter.reportPath = ./facter.json;
                amdgpu.overdrive.enable = true;
                enableRedistributableFirmware = true;
                i2c.enable = true;
            };

            # Keep microcode updated
            services.ucodenix = {
                enable = true;
                cpuModelId = "00A60F12";
            };

        };
}
