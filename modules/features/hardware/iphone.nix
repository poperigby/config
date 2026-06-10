{ ... }:

{
    den.aspects.hardware.provides.iphone.nixos = { pkgs, ... }: {
        # Core iPhone support
        services.usbmuxd.enable = true;

        # Required tools
        environment.systemPackages = with pkgs; [
            libimobiledevice
            ifuse
            gvfs
            libheif
            imagemagick
            exiftool
        ];

        # Udev rules for iOS devices
        services.udev.packages = [
            pkgs.libimobiledevice
        ];

        # Optional but helps with permissions
        users.users.cassidy.extraGroups = [
            "plugdev"
        ];
    };
}
