{ ... }:

{
  custom = {
    suites = {
      common.enable = true;
      gaming.enable = true;
      gui.enable = true;
    };
  };

  dconf.settings = {
    "org/gnome/settings-daemon/plugins/power" = {
      "sleep-inactive-ac-type" = "nothing";
      "sleep-inactive-ac-timeout" = 0;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
