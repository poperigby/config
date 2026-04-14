{ den, ... }:
{
    den.aspects.gaming = {
        homeManager =
            { config, pkgs, ... }:
            {
                home.packages = with pkgs; [
                    protontricks
                    heroic
                    protonplus
                    libstrangle
                    doomrunner
                    gzdoom
                    vkquake
                    prismlauncher
                    gpu-screen-recorder-gtk
                    shadps4
                ];

                home.sessionVariables.DOOMWADDIR = "${config.home.homeDirectory}/Games/Doom/IWADs";
                xdg.mimeApps.defaultApplications."application/vnd.adobe.flash.movie" = "ffdec.desktop";
            };

        nixos =
            { ... }:
            {
                programs.steam.enable = true;
                programs.gamemode.enable = true;
                programs.gamescope = {
                    enable = true;
                };
                boot.kernel.sysctl = {
                    "vm.max_map_count" = 2147483642;
                    "gpu_sched.sched_policy" = 0;
                    "amdgpu.freesync_video" = 1;
                };
            };

        provides.bethesda-user = {
            includes = [
                den.aspects.programs._.morrowind
            ];

            homeManager =
                { pkgs, ... }:
                {
                    home.packages = with pkgs; [ limo ];
                };
        };
    };
}
