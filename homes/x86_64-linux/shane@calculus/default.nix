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
    "org/gnome" = {
      "desktop/interface/scaling-factor" = 3;
      "settings-daemon/plugins/power" = {
        sleep-inactive-ac-type = "nothing";
        sleep-inactive-ac-timeout = 0;
      };
      shell = {
        disable-user-extensions = false;
        enabled-extensions = with pkgs.gnomeExtensions; [
          dash-to-dock.extensionUuid
        ];
      };
    };
  };

  programs.gnome-shell.extensions = [
    { package = pkgs.gnomeExtensions.dash-to-dock; }
  ];

  home.packages = with pkgs; [ dconf-editor ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
