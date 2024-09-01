{ config, lib, pkgs, ... }:

let
    inherit (lib)
        mkEnableOption
        mkIf
    ;

    cfg = config.poperigby.suites.common;
in
{
    options.poperigby.suites.common.enable = mkEnableOption "common settings";

    config = mkIf cfg.enable {
        # Specifies where my flake is located for nh
        # TODO: Shouldn't the be configDir?
        environment.sessionVariables.FLAKE = "/home/cassidy/nixos";

        boot = {
            # Use the latest version of the Linux kernel
            kernelPackages = pkgs.linuxPackages_latest;
            kernelParams = [
                # https://github.com/NixOS/nixpkgs/issues/312452
                "systemd.mask=systemd-vconsole-setup.service"
                "systemd.mask=dev-tpmrm0.device"
            ];
        };

        poperigby = {
            nix.enable = true;
            services = {
                distrobox.enable = true;
                envfs.enable = true;
                ld.enable = true;
                smartd.enable = true;
            };
            security = {
                secrets.enable = true;
                sudo.enable = true;
            };
            system = {
                bootloader.enable = true;
                locale.enable = true;
                zram.enable = true;
            };
            users = {
                enable = true;
                cassidy.enable = true;
            };
        };
    };
}
