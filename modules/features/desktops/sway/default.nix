{ den, ... }:
{
  den.aspects.desktops.provides.sway =
    { gui ? { } }:
    {
      includes = [
        den.aspects.programs._.imv
        den.aspects.programs._.imv-default
        den.aspects.programs._.rofi
        (den.aspects.programs._.swaylock { wallpaper = gui.wallpaper or null; })
        den.aspects.programs._.waybar
        den.aspects.programs._.wlogout

        den.aspects.services._.clipboard
        den.aspects.services._.gammastep
        (den.aspects.services._.swayidle {
          timeouts = gui.swayidleTimeouts or { lock = 1800; sleep = 3600; };
        })
        den.aspects.services._.swaync
        den.aspects.services._.swayosd
        den.aspects.services._.udiskie
      ];

      nixos = {
        security = {
          polkit.enable = true;
          pam.services.swaylock = { };
        };

        programs.dconf.enable = true;
        hardware.graphics.enable = true;
      };

      homeManager =
        { config, lib, pkgs, ... }:
        let
          inherit (lib) getExe getExe' mkIf mkOptionDefault readFile;
          colors = config.colorScheme.palette;
          fonts = config.fonts.fontconfig.defaultFonts;
        in
        {
          wayland.windowManager.sway = {
            enable = true;
            systemd.enable = true;
            package = pkgs.swayfx;
            checkConfig = false;
            config = {
              fonts = {
                # nixpkgs' sway config generator assumes a non-empty `fonts.names`.
                names = if (fonts.sansSerif or [ ]) == [ ] then [ "Noto Sans" ] else fonts.sansSerif;
                style = "normal";
                size = 11.0;
              };
              gaps.inner = 5;
              colors = {
                background = "#${colors.base00}";
                focused = rec {
                  background = "#${colors.base02}";
                  border = "#${colors.base01}";
                  childBorder = border;
                  indicator = "#${colors.base01}";
                  text = "#${colors.base07}";
                };
                focusedInactive = rec {
                  background = "#${colors.base00}";
                  border = "#${colors.base02}";
                  childBorder = border;
                  indicator = "#${colors.base02}";
                  text = "#${colors.base06}";
                };
                placeholder = {
                  background = "#${colors.base06}";
                  border = "#000000";
                  childBorder = "#${colors.base02}";
                  indicator = "#000000";
                  text = "#${colors.base07}";
                };
                unfocused = rec {
                  background = "#${colors.base00}";
                  border = "#${colors.base02}";
                  childBorder = border;
                  indicator = "#${colors.base02}";
                  text = "#${colors.base06}";
                };
                urgent = rec {
                  background = "#${colors.base08}";
                  border = "#${colors.base06}";
                  childBorder = border;
                  indicator = "#${colors.base06}";
                  text = "#${colors.base07}";
                };
              };

              input = {
                "type:keyboard".xkb_options = "caps:super";
                "type:touchpad".tap = "enabled";
              };
              output."*" = {
                mode = "${gui.resolution}@${toString gui.refreshRate}Hz";
                scale = toString gui.scale;
                bg = mkIf (gui.wallpaper != null) "${gui.wallpaper} fill";
                adaptive_sync = mkIf gui.vrr "on";
                max_render_time = mkIf gui.vrr "1";
                color_profile = mkIf (gui.colorProfileFile != null) "icc ${gui.colorProfileFile}";
              };

              modifier = "Mod4";
              menu = getExe pkgs.rofi-wayland;
              terminal = getExe pkgs.wezterm;
              defaultWorkspace = "workspace number 1";
              bars = [ ];
              startup = with pkgs; [
                { command = "${getExe element-desktop} --hidden"; }
                { command = "${getExe firefox}"; }
                { command = getExe autotiling-rs; }
                { command = getExe networkmanagerapplet; }
                { command = getExe signal-desktop; }
              ];

              floating = {
                titlebar = true;
                criteria = [
                  { title = "Friends List"; }
                  { title = "Steam Settings"; }
                  { title = "Create or select new Steam library folder"; }
                  { app_id = ".blueman-manager-wrapped"; }
                  { app_id = "com.saivert.pwvucontrol"; }
                  { title = "Extension: (Bitwarden Password Manager) - Bitwarden — Mozilla Firefox"; }
                  { title = "Please check or double click the module that you want to Quick Auto Clean"; }
                  { title = "Which files do you want to add this record to?"; }
                  { title = "Save changed files:"; }
                  { title = "Create ModGroup..."; }
                  { title = "In which module's .modgroups file should the new ModGroup be stored?"; }
                  { title = "Reloading ModGroups - Which ModGroups do you want to activate?"; }
                  { title = "Which files do you want to add these records to?"; }
                  { title = "Module Selection"; }
                  { title = "What modules should be included in the ModGroup?"; }
                ];
              };

              keybindings =
                let
                  mod = config.wayland.windowManager.sway.config.modifier;
                  swaymsg = getExe' pkgs.sway "swaymsg";
                  jq = getExe pkgs.jq;
                  menu = getExe config.programs.rofi.finalPackage;
                  browser = getExe pkgs.firefox;
                  term = config.wayland.windowManager.sway.config.terminal;
                  screenshot = getExe pkgs.custom.screenshot;
                  swayosd = getExe' pkgs.swayosd "swayosd-client";
                in
                mkOptionDefault {
                  "${mod}+q" = "kill";
                  "${mod}+Shift+q" = ''
                    exec kill -KILL $(${swaymsg} -t get_tree | ${jq} '.. | select(.type?) | select(.focused==true) | .pid')
                  '';
                  "${mod}+d" = "focus mode_toggle";
                  "${mod}+Shift+d" = "floating toggle";

                  "${mod}+Alt+0" = "move container to workspace number 10";
                  "${mod}+Alt+1" = "move container to workspace number 1";
                  "${mod}+Alt+2" = "move container to workspace number 2";
                  "${mod}+Alt+3" = "move container to workspace number 3";
                  "${mod}+Alt+4" = "move container to workspace number 4";
                  "${mod}+Alt+5" = "move container to workspace number 5";
                  "${mod}+Alt+6" = "move container to workspace number 6";
                  "${mod}+Alt+7" = "move container to workspace number 7";
                  "${mod}+Alt+8" = "move container to workspace number 8";
                  "${mod}+Alt+9" = "move container to workspace number 9";

                  "${mod}+space" = "exec ${menu} -show drun -show-icons";
                  "${mod}+Return" = "exec ${term}";
                  "${mod}+e" = "exec ${term} start ${getExe pkgs.yazi}";
                  "${mod}+b" = "exec ${browser}";
                  "${mod}+m" = "exec ${term} start ${getExe pkgs.bottom}";
                  "${mod}+n" = "exec ${getExe' pkgs.swaynotificationcenter "swaync-client"} -t -sw";

                  "${mod}+o" = "exec ${getExe config.programs.wlogout.package}";
                  "${mod}+p" = "exec ${getExe config.programs.swaylock.package}";

                  "Print" = "exec ${screenshot} fullscreen";
                  "Control+Print" = "exec ${screenshot} region";
                  "Shift+Print" = "exec ${screenshot} focused";

                  "${mod}+period" = "exec ${getExe pkgs.rofimoji}";
                  "${mod}+slash" = ''
                    exec ${menu} -modi clipboard:${getExe pkgs.custom.cliphist-rofi-img} -show clipboard -show-icons
                  '';

                  "XF86AudioRaiseVolume" = "exec ${swayosd} --output-volume raise";
                  "XF86AudioLowerVolume" = "exec ${swayosd} --output-volume lower";
                  "XF86AudioMute" = "exec ${swayosd} --output-volume mute-toggle";
                  "XF86MonBrightnessUp" = "exec ${swayosd} --brightness +10";
                  "XF86MonBrightnessDown" = "exec ${swayosd} --brightness -10";
                };
            };
          };

          wayland.windowManager.sway.extraConfig = ''
            corner_radius 10
          '';

          home.pointerCursor = {
            name = "Adwaita";
            package = pkgs.adwaita-icon-theme;
            size = 24;
            gtk.enable = true;
          };

          gtk =
            let
              css = readFile ./gtk.css;
            in
            {
              enable = true;
              theme = {
                name = "adw-gtk3-dark";
                package = pkgs.adw-gtk3;
              };
              iconTheme = {
                name = "Papirus-Dark";
                package = pkgs.papirus-icon-theme;
              };
              gtk4.extraCss = css;
              gtk3.extraCss = css;
            };

          qt = {
            enable = true;
            platformTheme.name = "gtk";
            style.name = "adwaita-dark";
          };

          dconf.settings = {
            "org/gnome/desktop/wm/preferences".button-layout = ":";
            "org/blueman/general".plugin-list = [
              "!ConnectionNotifier"
              "!StatusNotifierItem"
            ];
          };

          programs.bash.profileExtra = ''
            if [ "$(tty)" = "/dev/tty1" ]; then
              exec sway || exec bash
            fi
          '';

          home.packages = with pkgs; [
            grim
            nautilus
            pwvucontrol
            slurp
            wl-clipboard
          ];

          xdg.portal = {
            enable = true;
            config.common.default = "gtk";
            extraPortals = with pkgs; [
              xdg-desktop-portal-wlr
              xdg-desktop-portal-gtk
            ];
            config.common = {
              "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
              "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
            };
          };

          systemd.user.services = {
            polkit-gnome-authentication-agent-1 = {
              Unit = {
                Description = "polkit-gnome-authentication-agent-1";
                Wants = [ "graphical-session.target" ];
                After = [ "graphical-session.target" ];
              };
              Install.WantedBy = [ "graphical-session.target" ];
              Service = {
                Type = "simple";
                ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
                Restart = "on-failure";
                RestartSec = 1;
                TimeoutStopSec = 10;
              };
            };
            wayland-pipewire-idle-inhibit = {
              Unit = {
                Description = "Inhibit Wayland idling when media is played through pipewire";
                Documentation = "https://github.com/rafaelrc7/wayland-pipewire-idle-inhibit";
              };
              Install.WantedBy = [ "graphical-session.target" ];
              Service = {
                Type = "simple";
                ExecStart = "${getExe pkgs.wayland-pipewire-idle-inhibit}";
                Restart = "always";
                RestartSec = 10;
              };
            };
          };
        };
    };
}
