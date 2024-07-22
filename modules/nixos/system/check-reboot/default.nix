{ config, lib, inputs, system, ... }:

let
    cfg = config.poperigby.system.checkReboot;
in
{
    options.poperigby.system.checkReboot.enable = lib.mkEnableOption "check if reboot is required on system rebuild";

    config = lib.mkIf cfg.enable {
        system.activationScripts.checkReboot = # bash
        ''
            set -eou pipefail

            ${lib.getExe inputs.needsreboot.packages.${system}.default} 2> /dev/null

            if [ -f /var/run/reboot-required ]; then
                echo "REBOOT REQUIRED"
                cat /var/run/reboot-required
            fi
        '';
    };
}
