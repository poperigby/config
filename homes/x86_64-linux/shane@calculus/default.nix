{ pkgs, ... }:

{
  custom = {
    suites = {
      common.enable = true;
      gaming.enable = true;
      gui.enable = true;
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
      sleep-inactive-ac-timeout = 0;
    };
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = with pkgs.gnomeExtensions; [
        dash-to-dock.extensionUuid
      ];
    };
  };

  programs.gnome-shell.extensions = [
    { package = pkgs.gnomeExtensions.dash-to-dock; }
  ];

  home.packages = with pkgs; [ dconf-editor ];
}
