{ ... }:

{
    den.aspects.snowy.nixos = {
        hardware.facter.reportPath = ./facter.json;

        boot = {
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
        };

        # Keep microcode updated
        services.ucodenix = {
            enable = true;
            cpuModelId = "00A60F12";
        };

    };
}
