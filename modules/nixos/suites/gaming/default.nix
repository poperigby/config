{ config, lib, ... }:

let
  cfg = config.custom.suites.gaming;
in
{
    options.custom.suites.gaming.enable = lib.mkEnableOption "Enable gaming programs/tweaks";

    config = lib.mkIf cfg.enable {
        # This does some helpful Steam related tweaks (as well as installing Steam)
        programs.steam.enable = true;

        # Enable GameMode to optimize system performance on demand
        programs.gamemode.enable = true;

        # A microcompositor tailored for gaming
        programs.gamescope = {
            enable = true;
            # This breaks GameScope
            # capSysNice = true;
        };

        boot.kernel.sysctl = {
            # This value is used by SteamOS
            # See https://wiki.archlinux.org/title/Gaming#Increase_vm.max_map_count
            "vm.max_map_count" = 2147483642;
            # https://gitlab.freedesktop.org/drm/amd/-/issues/2516#note_2119750
            "gpu_sched.sched_policy" = 0;
            # https://github.com/swaywm/sway/issues/7370#issuecomment-1694485033
            "amdgpu.freesync_video" = 1;
        };
    };
}
