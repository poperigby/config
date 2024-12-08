{
    # Setup the primary disk
    disko.devices.disk.primary = {
        device = "/dev/disk/by-id/nvme-WD_Blue_SN580_1TB_244432808685";
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
        device = "/dev/disk/by-id/ata-ST4000DM004-2CV104_ZFN35CMF";
        fsType = "btrfs";
    };
}
