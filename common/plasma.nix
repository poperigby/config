{ config, lib, ... }:

let
  cfg = config.common.plasma;
in
{
    # Setup common.plasma options
    options.common.plasma = {
        enable = lib.mkEnableOption "Enable KDE Plasma";
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
