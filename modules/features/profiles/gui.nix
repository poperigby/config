{ den, ... }:
{
    den.aspects.gui = {
        includes = [
            den.aspects.services._.udisks2
            den.aspects.programs._.smile
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
                        monospace = [ "JetBrainsMono Nerd Font" ];
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

        # GUI machines grant packet capture access to Cassidy.
        provides.cassidy.user.extraGroups = [
            "wireshark"
        ];
    };
}
