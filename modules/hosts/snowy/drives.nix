{ ... }:
{
    den.aspects.snowy.drives.primary = {
        device = "/dev/nvme0n1";
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
                        name = "cryptroot";
                        type = "luks";
                        # This will only be used during initial partitioning
                        passwordFile = "/tmp/luks_password";
                        settings.allowDiscards = true;
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
    };

    # I define this is here instead of in disko.devices because I don't want Disko formatting these
    den.aspects.snowy.nixos.fileSystems = {
        "/mnt/ssd0" = {
            device = "/dev/disk/by-uuid/be9f123f-1da8-4821-bf2a-a1ac1f00d4ab";
            fsType = "ext4";
            options = [ "noatime" ];
        };
        "/mnt/hdd0" = {
            device = "/dev/disk/by-uuid/5d997a5b-4ddd-4962-bc36-13faf673d881";
            fsType = "ext4";
            options = [ "noatime" ];
        };
    };
}
