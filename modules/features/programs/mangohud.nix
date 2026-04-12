{ ... }:
{
    den.aspects.programs.provides.mangohud.homeManager.programs.mangohud = {
        enable = true;
        enableSessionWide = true;
        settings = {
            gpu_stats = true;
            gpu_temp = true;
            gpu_mem_clock = true;
            cpu_stats = true;
            cpu_temp = true;
            vram = true;
            ram = true;
            swap = true;
            fps = true;
            frametime = true;
            frame_timing = true;
            throttling_status = true;
            round_corners = 1;
            no_display = true;
            toggle_hud = "End";
            blacklist = "wezterm-gui";
        };
    };
}
