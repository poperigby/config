{
    # Setup the primary disk
    disko.devices.disk.primary = {
        device = "/dev/sdc";
        type = "disk";
        content = {
            type = "gpt";
            partitions = {
                esp = {
                    # This code corresponds to a EFI system partition
                    type = "EF00";
                    size = "500M";
                    content = {
                        type = "filesystem";
                        format = "vfat";
                        mountpoint = "/boot";
                    };
                };
                root = {
                    # Take up the rest of the space on the disk
                    size = "100%";
                    content = {
                        type = "btrfs";
                        subvolumes = {
                            "@" = {
                                mountpoint = "/";
                                mountOptions = [ "noatime" ];
                            };
                            "@home" = {
                                mountpoint = "/home";
                                mountOptions = [ "compress=zstd" "noatime" ];
                            };
                            "@nix" = {
                                mountpoint = "/nix";
                                mountOptions = [ "compress=zstd" "noatime" ];
                            };
                        };
                    };
                };
            };
        };
    };
    # This is defined here instead of in disko.devices because I don't want Disko formatting these
    # This is actually multiple drives combined into one filesystem
    fileSystems."/mnt/media" = {
        device = "/dev/disk/by-uuid/45208395-9c37-4bc4-ae87-c4ab5f39794b";
        fsType = "btrfs";
    };
}
