{ den, ... }:
{
    den.aspects.gaming = {
        homeManager =
            {
                config,
                lib,
                pkgs,
                ...
            }:
            {
                home.packages = with pkgs; [
                    local.jackify
                    doomrunner
                    gpu-screen-recorder-gtk
                    gzdoom
                    heroic
                    libstrangle
                    prismlauncher
                    protonplus
                    protontricks
                    r2modman
                    shadps4
                    vkquake
                ];

                home.sessionVariables.DOOMWADDIR = "${config.home.homeDirectory}/Games/Doom/IWADs";

                # Make Steam windows STAY on the workspace that I opened Steam on initially, while booting 😡
                xdg.dataFile."applications/steam.desktop".source =
                    let
                        steamYeeterEntry = pkgs.local.modifyDesktopEntry {
                            package = pkgs.steam;
                            desktopFile = "steam.desktop";
                            replace.Exec = "${lib.getExe pkgs.local.steam-yeeter} %U";
                        };
                    in
                    "${steamYeeterEntry}/share/applications/steam.desktop";
            };

        nixos =
            { pkgs, ... }:
            {
                programs.steam = {
                    enable = true;
                    extraPackages = with pkgs; [
                        # hidapi is required by Steam's controller firmware updater. Without it
                        # Steam logs `ImportError: Unable to load ... libhidapi-hidraw.so` and
                        # shows "Failed to update Steam Controller firmware" for the Steam Controller 2026.
                        hidapi
                    ];
                    extraCompatPackages = with pkgs; [
                        proton-ge-bin
                    ];
                    # Fixes right trackpad not controlling the mouse
                    extest.enable = true;
                };

                # Installs Valve's udev rules (60-steam-input.rules etc.) so the
                # Steam Controller's hidraw nodes are accessible without root.
                hardware.steam-hardware.enable = true;

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

        provides.morrowind = {
            includes = [
                den.aspects.programs._.morrowind
            ];
        };
    };
}
