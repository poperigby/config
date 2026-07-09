{ lib, ... }:
{
    den.aspects.nestor.nixos = {
        fileSystems = {
            "/" = {
                device = lib.mkForce "/dev/disk/by-label/NIXOS_SD";
            };
            "/boot/firmware" = {
                device = lib.mkForce "/dev/disk/by-label/FIRMWARE";
            };
        };

        disko.devices.disk.primary = {
            device = "/dev/mmcblk0";
            type = "disk";
            content = {
                type = "gpt";
                partitions = {
                    FIRMWARE = {
                        label = "FIRMWARE";
                        type = "0700";
                        size = "1024M";
                        content = {
                            type = "filesystem";
                            format = "vfat";
                            mountpoint = "/boot/firmware";
                            mountOptions = [ "noatime" ];
                        };
                    };
                    root = {
                        label = "NIXOS_SD";
                        type = "8305";
                        size = "100%";
                        content = {
                            type = "filesystem";
                            format = "ext4";
                            mountpoint = "/";
                            mountOptions = [ "noatime" ];
                        };
                    };
                };
            };
        };
    };
}
