{ config, lib, ... }:

let
  cfg = config.poperigby.suites.common;
in
{
    options.poperigby.suites.common.enable = lib.mkEnableOption "Enable common settings";

    config = lib.mkIf cfg.enable {
        # Specifies where my flake is located for nh
        environment.sessionVariables.FLAKE = "/home/cassidy/nixos";

        poperigby = {
            nix.enable = true;
            services = {
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
                fonts.enable = true;
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
