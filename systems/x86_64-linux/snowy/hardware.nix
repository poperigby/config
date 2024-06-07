{ config, lib, modulesPath, ... }:

{
    imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
    ];

    boot = {
        initrd = {
            availableKernelModules = [
                "ahci"
                "nvme"
                "sd_mod"
                "sr_mod"
                "sr_mod"
                "usb_storage"
                "usbhid"
                "xhci_pci"
            ];
            kernelModules = [];
        };
        kernelModules = [
            "k10temp"
            "kvm-amd"
            "nct6775"
        ];
        extraModulePackages = [];
    };

    # I define this is hear instead of in drives.nix because I don't want Disko formatting these
    fileSystems = {
        "/mnt/ssd0" = {
            device = "/dev/disk/by-uuid/be9f123f-1da8-4821-bf2a-a1ac1f00d4ab";
            fsType = "ext4";
        };
        "/mnt/hdd0" = {
            device = "/dev/disk/by-uuid/5d997a5b-4ddd-4962-bc36-13faf673d881";
            fsType = "ext4";
        };
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
