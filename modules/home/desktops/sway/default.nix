{
  config,
  inputs,
  lib,
  pkgs,
  system,
  ...
}:

let
  inherit (lib)
    getExe
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.desktops.sway;
  gui = config.custom.suites.gui;
in
{
  options.custom.desktops.sway.enable = mkEnableOption "Enable Sway window manager";

  imports = [
    ./keybinds.nix
    ./windowRules.nix
    ./styling.nix
  ];

  config = mkIf cfg.enable {
    wayland.windowManager.sway = {
      enable = true;
      # Integrates Sway with systemd, which will allow applications to depend on it
      # by depending on "graphical.target".
      systemd.enable = true;
      package = inputs.swayfx.legacyPackages.${system}.swayfx;
      # Required for SwayFX to work
      checkConfig = false;
      config = {
        input = {
          "type:keyboard" = {
            # Rebind Caps Lock to Super key (Mod4)
            xkb_options = "caps:super";
          };
          "type:touchpad" = {
            # Enable tap to click
            tap = "enabled";
          };
        };
        output = {
          "*" = {
            mode = "${gui.resolution}@${toString gui.refreshRate}Hz";
            scale = toString gui.scale;
            bg = mkIf (gui.wallpaper != null) "${gui.wallpaper} fill";
            adaptive_sync = mkIf gui.vrr "on";
            max_render_time = mkIf gui.vrr "1";
          };
        };
        modifier = "Mod4";
        menu = getExe pkgs.rofi-wayland;
        terminal = getExe pkgs.wezterm;
        defaultWorkspace = "workspace number 1";
        # We'll just use systemd to start Waybar
        bars = [ ];
        # Programs to launch when Sway starts
        startup = [
          { command = "${getExe pkgs.firefox}"; }
          { command = "${getExe pkgs.element-desktop} --hidden"; }
          { command = getExe pkgs.autotiling-rs; }
        ];
      };
    };

    # Start Sway if we open a login shell on TTY1
    # Fallback to bash shell if Sway fails to start
    programs.bash.profileExtra = # bash
      ''
        if [ "$(tty)" = "/dev/tty1" ]; then
            exec sway || exec bash
        fi
      '';

    # Packages that don't need any configuration
    home.packages = with pkgs; [
      grim
      nautilus
      pwvucontrol
      slurp
    ];

    custom = {
      programs = {
        imv = {
          enable = true;
          default = true;
        };
        rofi.enable = true;
        swaylock.enable = true;
        waybar.enable = true;
        wlogout.enable = true;
      };
      services = {
        clipboard.enable = true;
        gammastep.enable = true;
        swayidle.enable = true;
        swaync.enable = true;
        swayosd.enable = true;
        udiskie.enable = true;
      };
    };

    xdg.portal = {
      enable = true;
      # Fallback portal
      config.common.default = "gtk";
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
      config.common = {
        # The WLR portal can only handle these two
        "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
      };
    };
  };
}
