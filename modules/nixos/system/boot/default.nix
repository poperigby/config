{ config, lib, ... }:

let
  cfg = config.poperigby.system.bootloader;
in
{
    options.poperigby.system.bootloader.enable = lib.mkEnableOption "Enable bootloader settings";

    config = lib.mkIf cfg.enable {
        boot.loader = {
            systemd-boot = {
                enable = true;
                # Limit the number of generations to keep
                configurationLimit = 5;
            };
            efi.canTouchEfiVariables = true;
        };
    };
}
