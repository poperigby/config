{ config, lib, pkgs, ... }:

let
  cfg = config.poperigby.suites.common;
in
{
    options.poperigby.suites.common.enable = lib.mkEnableOption "Enable common settings";

    config = lib.mkIf cfg.enable {
        # Specifies where my flake is located for nh
        # TODO: Shouldn't the be configDir?
        environment.sessionVariables.FLAKE = "/home/cassidy/nixos";

        # Use the latest version of the Linux kernel
        boot.kernelPackages = pkgs.linuxPackages_latest;

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
