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
            icon = "${pkgs.morewaita-icon-theme}/share/icons/MoreWaita/apps/scalable/discord.svg";
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
