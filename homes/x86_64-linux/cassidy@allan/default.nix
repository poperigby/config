{ ... }:

{
  custom = {
    desktops.sway.enable = true;
    suites = {
      common.enable = true;
      gui = {
        enable = true;
        resolution = "2256x1504";
        scale = 1.5;
        refreshRate = 60;
        wallpaper = ./wallpaper.jpg;
      };
    };
    services.swayidle.timeouts = {
      # 10 minutes
      lock = 600;
      # 15 minutes
      sleep = 900;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
