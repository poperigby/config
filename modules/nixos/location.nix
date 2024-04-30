# Automatic location provider
{ config, lib, ... }:

let
  cfg = config.common.os.location;
in
{
    options.common.os.location.enable = lib.mkEnableOption "Enable automatic location provider";

    config = lib.mkIf cfg.enable {
        services.geoclue2.enable = true;
    };
}
