{
    # Setup the primary disk
    disko.devices.disk.sda = {
        device = "/dev/sda";
        type = "disk";
        content = {
            type = "gpt";
            partitions = {
                esp = {
                    name = "ESP";
                    type = "EF00";
                    size = "500M";
                    content = {
                        type = "filesystem";
                        format = "vfat";
                        mountpoint = "/boot";
                    };
                };
                root = {
                    size = "100%";
                    content = {
                        type = "btrfs";
                        subvolumes = {
                            "@root" = {
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
}
