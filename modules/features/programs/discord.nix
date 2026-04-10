{ den, inputs, ... }:
{
  den.aspects.programs.provides.discord.homeManager =
    { ... }:
    {
      imports = [ inputs.nixcord.homeModules.nixcord ];
      programs.nixcord = {
        enable = true;
        vesktop.enable = true;
        discord.enable = false;
        config.plugins = {
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
}
