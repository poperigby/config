{ config, lib, modulesPath, ... }:

{
    imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
    ];

    boot = {
        initrd = {
            availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
            kernelModules = [];
        };
        kernelModules = [ "k10temp" "nct6775" ];
        extraModulePackages = [];
    };

    # This is actually multiple drives combined into one filesystem
    fileSystems."/mnt/media" = {
        device = "/dev/disk/by-uuid/45208395-9c37-4bc4-ae87-c4ab5f39794b";
        fsType = "btrfs";
    };

    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    networking.useDHCP = lib.mkDefault true;
    # networking.interfaces.enp1s0.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
