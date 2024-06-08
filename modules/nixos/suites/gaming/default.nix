{ config, lib, ... }:

let
  cfg = config.poperigby.suites.gaming;
in
{
    options.poperigby.suites.gaming.enable = lib.mkEnableOption "Enable gaming programs/tweaks";

    config = lib.mkIf cfg.enable {
        # This does some helpful Steam related tweaks (as well as installing Steam)
        programs.steam.enable = true;

        # Enable GameMode to optimize system performance on demand
        programs.gamemode.enable = true;

        # A microcompositor tailored for gaming
        programs.gamescope = {
            enable = true;
            # Add cap_sys_nice capability to the GameScope binary so that it may renice itself
            capSysNice = true;
        };

        boot.kernel.sysctl = {
            # This value is used by SteamOS
            # See https://wiki.archlinux.org/title/Gaming#Increase_vm.max_map_count
            "vm.max_map_count" = 2147483642;
            # https://gitlab.freedesktop.org/drm/amd/-/issues/2516#note_2119750
            "gpu_sched.sched_policy" = 0;
        };
    };
}
