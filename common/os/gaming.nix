{ config, lib, ... }:

let
  cfg = config.common.os.gaming;
in
{
    options.common.os.gaming.enable = lib.mkEnableOption "Enable gaming related programs/tweaks";

    config = lib.mkIf cfg.enable {
        # Enable GameMode to optimize system performance on demand
        programs.gamemode.enable = true;

        # A microcompositor tailored for gaming
        programs.gamescope = {
            enable = true;
            # Add cap_sys_nice capability to the GameScope binary so that it may renice itself
            capSysNice = true;
        };
    };
}
