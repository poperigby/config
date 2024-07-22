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

            ${inputs.needsreboot.packages.${system}.default}/bin/nixos-needsreboot 2> /dev/null

            if [ -f /var/run/reboot-required ]; then
                cat /var/run/reboot-required
            fi
        '';
    };
}
