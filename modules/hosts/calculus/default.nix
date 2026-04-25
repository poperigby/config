{ den, ... }:
{
    den.aspects.calculus = {
        provides.to-users.includes = with den.aspects; [
            # Profiles
            common
            gui
            gaming

            # Desktop
            desktops._.gnome

            # System
            (system._.boot { })

            # Hardware
            hardware._.audio

            # Services
            services._.earlyoom

            # CLI
            programs._.atuin
            programs._.bat
            programs._.bottom
            programs._.direnv
            programs._.fish
            programs._.git
            programs._.gpg
            programs._.jujutsu
            programs._.neovim
            programs._.starship
            programs._.tealdeer
            programs._.television
            programs._.yazi

            # Development services
            services._.lspmux

            # GUI apps
            programs._.discord
            programs._.element-desktop
            programs._.firefox
            programs._.mpv
            programs._.wezterm
            programs._.bottom-gui
            programs._.neovim-gui
            programs._.yazi-gui

            # Gaming
            programs._.mangohud
            services._.ludusavi
            services._.joystickwake
        ];

        nixos = {
            services.openssh.enable = true;
            time.timeZone = "America/Los_Angeles";
            networking.networkmanager.enable = true;

            # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
            system.stateVersion = "23.11";
        };

        provides.shane = {
            homeManager =
                { pkgs, ... }:
                {
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
                };
        };
    };
}
