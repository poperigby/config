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

        _.to-users.includes = [ den._.define-user ];

        nixos = {
            imports = [
                ./_nixos/drives.nix
                ./_nixos/hardware.nix
            ];

            services.openssh.enable = true;
            time.timeZone = "America/Los_Angeles";
            networking.networkmanager.enable = true;

            # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
            system.stateVersion = "23.11";
        };

        provides.shane = {
            includes = [
                den.aspects.common._.user
                den.aspects.gui._.user
                den.aspects.gaming._.user
            ];

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
