{ den, ... }:
{
    den.aspects.gaming = {
        includes = with den.aspects; [
            programs._.gpu-screen-recorder
            programs._.mangohud
            programs._.steam
            services._.joystickwake
        ];

        homeManager =
            {
                config,
                pkgs,
                ...
            }:
            {
                home.packages = with pkgs; [
                    doomrunner
                    heroic
                    libstrangle
                    local.jackify
                    prismlauncher
                    protonplus
                    protontricks
                    r2modman
                    shadps4
                    slade-unstable
                    uzdoom
                    vkquake
                ];

                home.sessionVariables.DOOMWADDIR = "${config.home.homeDirectory}/Games/Doom/IWADs";
            };

        nixos = {
            boot.kernel.sysctl = {
                "vm.max_map_count" = 2147483642;
                "gpu_sched.sched_policy" = 0;
                "amdgpu.freesync_video" = 1;
            };

            services.lact.enable = true;
        };

        provides.morrowind = {
            includes = [
                den.aspects.programs._.morrowind
            ];
        };
    };
}
