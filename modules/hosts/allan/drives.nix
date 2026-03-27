{ inputs, ... }:

{

    flake-file.inputs.disko.url = "github:nix-community/disko";

    den.aspects.allan.nixos = {
        imports = [ inputs.disko.nixosModules.disko ];

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
    };
}
