{ config, lib, ... }:

let
  cfg = config.poperigby.suites.gaming;
in
{
    options.poperigby.suites.gaming = {
        enable = lib.mkEnableOption "Enable gaming programs/tweaks";
        amd.enable = lib.mkEnableOption "Enable AMD specific tweaks";
    };

    config = lib.mkIf cfg.enable (lib.mkMerge [
        {
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
            };
        }
        # AMD specific options
        (lib.mkIf cfg.amd.enable {
            # poperigby.services.lact = {
                # enable = true;
                # settings = {
                #     gpus = [
                #         "1002:731F-1DA2:E411-0000:0d:00.0" = {
                #             fan_control_enabled = false;
                #             performance_level = "high";
                #         }
                #     ];
                # };
            # };
         })
    ]);
}
