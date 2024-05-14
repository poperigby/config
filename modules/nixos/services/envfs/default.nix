{ config, lib, ... }:

let
  cfg = config.poperigby.services.envfs;
in
{
    options.poperigby.services.envfs.enable = lib.mkEnableOption "Enable EnvFS";

    config = lib.mkIf cfg.enable {
        # Dynamically populates contents of /bin and /usr/bin, allowing
        # programs that assume FHS to work.
        services.envfs.enable = true;
    };
}
