{ config, lib, ... }:

let
    inherit (lib)
        mkEnableOption
        mkIf
        ;

    cfg = config.custom.hardware.printing;
in
{
    options.custom.hardware.printing.enable = mkEnableOption "printing";

    config = mkIf cfg.enable {
        services = {
            printing = {
                enable = true;
            };
            # Required for driverless network printing
            avahi = {
                enable = true;
                nssmdns4 = true;
                openFirewall = true;
            };
        };
    };
}
