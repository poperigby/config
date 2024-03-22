{
    # Setup the primary disk
    disko.devices.disk.sda = {
        device = "/dev/sda";
        type = "disk";
        content = {
            type = "gpt";
            partitions = {
                esp = {
                    # Partition label
                    name = "esp";
                    # This code corresponds to EFI system partition
                    type = "EF00";
                    size = "500M";
                    content = {
                        type = "filesystem";
                        format = "vfat";
                        mountpoint = "/boot";
                    };
                };
                root = {
                    name = "root";
                    # Take up the rest of the space on the disk
                    size = "100%";
                    content = {
                        type = "btrfs";
                        subvolumes = {
                            "/root" = {
                                mountpoint = "/";
                                mountOptions = [ "noatime" ];
                            };
                            "/home" = {
                                mountpoint = "/home";
                                mountOptions = [ "compress=zstd" "noatime" ];
                            };
                            "/nix" = {
                                mountpoint = "/nix";
                                mountOptions = [ "compress=ztsd" "noatime" ];
                            };
                        };
                    };
                };
            };
        };
    };
}
