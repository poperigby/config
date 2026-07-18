{ den, ... }:
{
    den.aspects.gui = {
        includes = [
            den.aspects.services._.xembed-sni-proxy
            den.aspects.system._.plymouth
        ];

        homeManager =
            { pkgs, ... }:
            {
                fonts.fontconfig = {
                    enable = true;
                    defaultFonts = {
                        sansSerif = [
                            "Noto Sans"
                            "Noto Sans CJK"
                        ];
                        serif = [
                            "Noto Sans"
                            "Noto Sans CJK"
                        ];
                        monospace = [ "JetBrainsMonoNL Nerd Font Mono" ];
                        emoji = [ "Noto Color Emoji" ];
                    };
                };

                home.packages = with pkgs; [
                    bottles
                    gimp3
                    inkscape
                    libreoffice
                    nerd-fonts.jetbrains-mono
                    noto-fonts
                    noto-fonts-cjk-sans
                    noto-fonts-color-emoji
                    signal-desktop
                    tenacity
                    tor-browser
                    wl-clipboard-rs
                ];

                xdg.mimeApps.enable = true;
                home.sessionVariables.NIXOS_OZONE_WL = 1;
            };

        nixos =
            { pkgs, ... }:
            {
                services.udisks2.enable = true;
                programs.wireshark.enable = true;
                environment.systemPackages = with pkgs; [ wireshark ];
                services.systembus-notify.enable = true;
            };

        # GUI users get packet capture access for Wireshark.
        provides.user.extraGroups = [
            "wireshark"
        ];
    };
}
