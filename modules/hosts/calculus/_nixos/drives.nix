{
    # Setup the primary disk
    disko.devices.disk.primary = {
        device = "/dev/disk/by-id/ata-SanDisk_SSD_PLUS_2000GB_21469T446305";
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
                        # https://github.com/NixOS/nixpkgs/issues/279362
                        mountOptions = [ "umask=007" ];
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
                                mountOptions = [
                                    "compress=zstd"
                                    "noatime"
                                ];
                            };
                            "@nix" = {
                                mountpoint = "/nix";
                                mountOptions = [
                                    "compress=zstd"
                                    "noatime"
                                ];
                            };
                            "@snapshots" = {
                                mountpoint = "/.snapshots";
                                mountOptions = [
                                    "compress=zstd"
                                    "noatime"
                                ];
                            };
                        };
                    };
                };
            };
        };
    };
}
