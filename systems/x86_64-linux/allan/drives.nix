{ config, ... }:

{
    # Setup the primary disk
    disko.devices.disk.primary = {
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
                        name = "root";
                        type = "luks";
                        passwordFile = config.sops.secrets."allan/luks_password".path;
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
                                    mountOptions = [ "compress=zstd" "noatime" ];
                                };
                                "@nix" = {
                                    mountpoint = "/nix";
                                    mountOptions = [ "compress=ztsd" "noatime" ];
                                };
                            };
                        };
                    };
                };
            };
        };
    };

    sops.secrets."allan/luks_password" = {};
}
