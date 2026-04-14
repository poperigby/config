{ den, ... }:
{
    den.aspects.calculus = {
        includes = [
            den.aspects.common
            den.aspects.gui
            den.aspects.gaming

            (den.aspects.system._.boot { })
            den.aspects.desktops._.gnome
            den.aspects.hardware._.audio
            den.aspects.services._.earlyoom
        ];

        provides.to-users = {
            includes = [
                den._.define-user
                den.aspects.programs._.atuin
                den.aspects.programs._.bat
                den.aspects.programs._.bottom
                den.aspects.programs._.direnv
                den.aspects.programs._.fish
                den.aspects.programs._.git
                den.aspects.programs._.gpg
                den.aspects.programs._.jujutsu
                den.aspects.programs._.neovim
                den.aspects.programs._.starship
                den.aspects.programs._.tealdeer
                den.aspects.programs._.television
                den.aspects.programs._.yazi
                den.aspects.services._.lspmux
                den.aspects.programs._.discord
                den.aspects.programs._.element-desktop
                den.aspects.programs._.firefox
                den.aspects.programs._.mpv
                den.aspects.programs._.wezterm
                den.aspects.programs._.bottom-gui
                den.aspects.programs._.neovim-gui
                den.aspects.programs._.yazi-gui
                den.aspects.programs._.mangohud
                den.aspects.services._.ludusavi
                den.aspects.services._.joystickwake
            ];
            homeManager = {
                imports = [
                    den.aspects.common.homeManager
                    den.aspects.gui.homeManager
                    den.aspects.gaming.homeManager
                ];
            };
        };

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
