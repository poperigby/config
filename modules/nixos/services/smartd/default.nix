{ config, lib, pkgs, ... }:

let
  cfg = config.poperigby.services.smartd;
in
{
    options.poperigby.services.smartd = {
        enable = lib.mkEnableOption "Enable smartd to monitor drives";
    };

    config = lib.mkIf cfg.enable {
        services.smartd = {
            enable = true;
        };

        environment.systemPackages = [ pkgs.smartmontools ];
    };
}
