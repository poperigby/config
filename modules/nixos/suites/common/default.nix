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
            # Nix tweaks
            nix.enable = true;
            services = {
                envfs.enable = true;
                ld.enable = true;
            };
            security = {
                secrets.enable = true;
                sudo.enable = true;
            };
            system = {
                boot.enable = true;
                locale.enable = true;
                zram.enable = true;
            };
            # Enable my user
            users.cassidy.enable = true;
        };
    };
}
