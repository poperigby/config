{ config, lib, ... }:

let
  cfg = config.modules.nixos.plasma;
in
{
    # Setup modules.nixos.plasma options
    options.modules.nixos.plasma = {
        enable = lib.mkEnableOption "Enable KDE Plasma";
    };

    # Only enable KDE Plasma if `modules.nixos.plasma.enable` is true
    config = lib.mkIf cfg.enable {
        services.xserver = {
            # Enable X11 just in case
            enable = true;
            displayManager.sddm.enable = true;
            desktopManager.plasma5.enable = true;
        };
    };
}
