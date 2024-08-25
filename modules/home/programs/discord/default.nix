{ config, lib, ... }:

let
    cfg = config.poperigby.programs.discord;
in
{
    options.poperigby.programs.discord.enable = lib.mkEnableOption "Discord";

    config = lib.mkIf cfg.enable {
        programs.nixcord = {
            enable = true;
            config = {
                plugins = {
                    alwaysTrust.enable = true;
                    anonymiseFileNames.enable = true;
                    clearURLs.enable = true;
                    crashHandler.enable = true;
                    dearrow.enable = true;
                    imageZoom.enable = true;
                    noServerEmojis.enable = true;
                    webKeybinds.enable = true;
                    webScreenShareFixes.enable = true;
                };
            };
        };
    };
}
