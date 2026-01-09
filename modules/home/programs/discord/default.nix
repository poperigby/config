{
    config,
    inputs,
    lib,
    ...
}:

let
    inherit (lib)
        mkEnableOption
        mkIf
        ;

    cfg = config.custom.programs.discord;
in
{
    imports = [ inputs.nixcord.homeModules.nixcord ];

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
