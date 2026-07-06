{ self, inputs, ... }:
{
    flake.installerImages = {
        nestor =
            (self.nixosConfigurations.nestor.extendModules {
                modules = [
                    inputs.nixos-raspberrypi.nixosModules.sd-image
                    (
                        { config, lib, ... }:
                        {
                            boot.supportedFilesystems = lib.mkForce [
                                "ext4"
                                "vfat"
                            ];

                            sdImage.compressImage = false;

                            fileSystems = {
                                "/" = {
                                    device = lib.mkForce "/dev/disk/by-label/NIXOS_SD";
                                };
                                "/boot/firmware" = {
                                    device = lib.mkForce "/dev/disk/by-label/FIRMWARE";
                                };
                            };

                            image.baseName =
                                let
                                    cfg = config.boot.loader.raspberry-pi;
                                in
                                lib.mkForce "nixos-image-nestor-rpi${cfg.variant}-${cfg.bootloader}";
                        }
                    )
                ];
            }).config.system.build.sdImage;
    };
}
