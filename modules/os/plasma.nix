{ config, lib, ... }:

let
  cfg = config.modules.os.plasma;
in
{
    # Setup modules.os.plasma options
    options.modules.os.plasma = {
        enable = lib.mkEnableOption "Enable KDE Plasma";
    };

    # Only enable KDE Plasma if `modules.os.plasma.enable` is true
    config = lib.mkIf cfg.enable {
        services.xserver = {
            # Enable X11 just in case
            enable = true;
            displayManager.sddm.enable = true;
            desktopManager.plasma5.enable = true;
        };
    };
}
