{ config, lib, pkgs, ... }:

let
    cfg = config.poperigby.programs.vesktop;
in
{
    options.poperigby.programs.vesktop.enable = lib.mkEnableOption "Enable Vesktop, a better Discord client";

    config = lib.mkIf cfg.enable {
        home.packages = [ pkgs.vesktop ];

        # Use the default Discord icon
        xdg.desktopEntries.vesktop = {
            name = "Discord";
            genericName = "Internet Messenger";
            icon = "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark/64x64/apps/discord.svg";
            exec = "vesktop %U";
            categories = [
                "Network"
                "InstantMessaging"
                "Chat"
            ];
            settings = {
                Keywords = "discord;vencord;electron;chat";
                StartupWMClass = "Discord";
            };
        };
    };
}
