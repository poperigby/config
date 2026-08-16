{ den, ... }:
{
    den.aspects.gui = {
        includes = [
            den.aspects.services._.udisks
            den.aspects.services._.xembed-sni-proxy
            den.aspects.system._.plymouth
        ];

        homeManager =
            {
                config,
                lib,
                pkgs,
                ...
            }:
            let
                inherit (lib) getExe mkIf;
            in
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

                xdg.desktopEntries = {
                    bottom = mkIf config.programs.bottom.enable {
                        name = "Bottom";
                        genericName = "System Monitor";
                        icon = "utilities-system-monitor";
                        exec = "btm";
                        terminal = true;
                        type = "Application";
                        categories = [ "System" ];
                    };
                    nvim = mkIf config.programs.neovim.enable {
                        name = "Neovim";
                        genericName = "Text Editor";
                        exec = "${getExe pkgs.wezterm} start nvim %F";
                        terminal = false;
                        type = "Application";
                        icon = "nvim";
                        categories = [
                            "Utility"
                            "TextEditor"
                        ];
                        mimeType = [ "text/plain" ];
                    };
                    yazi = mkIf config.programs.yazi.enable {
                        name = "Yazi";
                        genericName = "File Browser";
                        exec = "${getExe pkgs.yazi} %f";
                        icon = ../programs/yazi/icon.png;
                        terminal = true;
                        categories = [
                            "System"
                            "FileTools"
                            "FileManager"
                        ];
                        mimeType = [ "inode/directory" ];
                    };
                };

                programs.yazi.keymap.mgr.prepend_keymap = mkIf config.programs.yazi.enable [
                    {
                        on = [ "<C-n>" ];
                        run = "shell '${getExe pkgs.ripdrag} \"$@\" -x 2>/dev/null &' --confirm";
                        description = "Open ripdrag for dragging and dropping";
                    }
                ];
            };

        nixos =
            { pkgs, ... }:
            {
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
