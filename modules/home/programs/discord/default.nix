{ config, lib, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.programs.discord;
in
{
  options.custom.programs.discord.enable = mkEnableOption "Discord";

  config = mkIf cfg.enable {
    programs.nixcord = {
      enable = true;
      vesktop.enable = true;
      discord.enable = false;
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
