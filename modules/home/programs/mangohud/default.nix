{ config, lib, ... }:

let
  cfg = config.custom.programs.mangohud;
in
{
  options.custom.programs.mangohud.enable = lib.mkEnableOption "Enable MangoHUD";

  config = lib.mkIf cfg.enable {
    programs.mangohud = {
      enable = true;
      # Enable MangoHUD for all applications that support it
      enableSessionWide = true;
      settings = {
        # Display the current GPU information
        gpu_stats = true;
        gpu_temp = true;
        gpu_mem_clock = true;
        # Display the current CPU information
        cpu_stats = true;
        cpu_temp = true;
        # Display system VRAM / RAM / swap space usage
        vram = true;
        ram = true;
        swap = true;
        # Display FPS and frametime
        fps = true;
        frametime = true;
        # Frame timing graph
        frame_timing = true;
        # Display GPU throttling status. Only shows if
        # throttling is currently happening
        throttling_status = true;
        # Make the corners round
        round_corners = 1;
        # Hide the HUD by default
        no_display = true;
        # Keybinds
        toggle_hud = "End";
        # Application blacklist
        blacklist = "wezterm-gui";
      };
    };
  };
}
