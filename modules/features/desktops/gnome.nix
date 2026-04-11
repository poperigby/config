{ den, ... }:
{
    den.aspects.desktops.provides.gnome.nixos =
        { pkgs, ... }:
        {
            services = {
                displayManager.gdm.enable = true;
                desktopManager.gnome.enable = true;
                # For system tray icons
                udev.packages = [ pkgs.gnome-settings-daemon ];
            };

            environment.systemPackages = with pkgs.gnomeExtensions; [
                # For system tray icons
                appindicator
            ];
        };
}
