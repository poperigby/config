{ config, lib, ... }:

let
  cfg = config.common.plasma;
in
{
    # Setup common.backups options
    options.common.plasma.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
    };

    # Only enable KDE Plasma if `common.plasma.enable` is true
    config = lib.mkIf cfg.enable {
        services.xserver = {
            # Enable X11 just in case
            enable = true;
            displayManager.sddm.enable = true;
            desktopManager.plasma5.enable = true;
        };
    };
}
